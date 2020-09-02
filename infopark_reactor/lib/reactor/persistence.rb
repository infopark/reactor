require "reactor/attributes/link_list_from_accessor"
require "reactor/attributes/link_list_from_attr_values"

module Reactor
  module Persistence
    # Provides API for writing into the Content Manager.
    # It aims to be just like ActiveRecord::Persistence, so that
    # the difference for the developer is minimal
    # If the method is marked as exception raising, then it should
    # be expected also to raise Reactor::Cm::XmlRequestError
    # when generic write/connection error occurs.
    #
    # It should support all generic model callbacks, plus
    # complete set of callbacks for release action (before/after/around).
    #
    # @raise [Reactor::Cm::XmlRequestError] generic error occoured
    module Base
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:define_model_callbacks, :release)
        base.class_eval do
          before_create :sanitize_name
          before_create :trim_crul_attributes
        end
      end

      # Releases the object. Returns true on success,
      # false when one of the following occurs:
      # 1. user lacks the permissions
      # 2. the object has already been released
      # 3. object is invalid
      # 4. other error occoured
      # @param comment [String] comment to leave for the next user
      def release(comment = nil)
        release!(comment)
      rescue Reactor::Cm::XmlRequestError, ActiveRecord::RecordInvalid, Reactor::NotPermitted, Reactor::AlreadyReleased
        false
      end

      # Removes the working version of the object,
      # if it exists
      # @param comment [String] comment to leave for the next user
      # @return [true]
      def revert(comment = nil)
        revert!(comment)
      end

      # Removes the working version of the object,
      # if it exists
      # @param comment [String] comment to leave for the next user
      # @return [true]
      # @note There is no difference between #revert and #revert!
      def revert!(comment = nil)
        crul_obj.revert!(comment)
        reload
        true
      end

      # Releases the object. Returns true on succes, can raise exceptions
      # @param comment [String] comment to leave for the next user
      # @raise [Reactor::AlreadyReleased]
      # @raise [ActiveRecord::RecordInvalid] validations failed
      # @raise [Reactor::NotPermitted] current user lacks required permissions
      def release!(comment = nil)
        run_callbacks(:release) do
          raise(Reactor::AlreadyReleased) unless edited_or_committed?

          crul_obj.release!(comment)
          reload
        end
        true
      end

      # Makes the current user the editor of the object. Returns true when
      # user is already the editor or take succeded,
      # false when one of the following occurs:
      # 1. user lacks the permissions
      # 2. the object has not beed edited
      # 3. other error occured
      # @param comment [String] comment to leave for the next user
      def take(comment = nil)
        take!(comment)
        true
      rescue Reactor::Cm::XmlRequestError, Reactor::NotPermitted, Reactor::NoWorkingVersion
        false
      end

      # Makes the current user the editor of the object. Returns true when
      # user is already the editor or take succeded. Raises exceptions
      # @param comment [String] comment to leave for the next user
      # @raise [Reactor::NoWorkingVersion] there is no working version of the object
      # @raise [Reactor::NotPermitted] current user lacks required permissions
      def take!(comment = nil)
        raise(Reactor::NoWorkingVersion) unless really_edited?

        # TODO: refactor the if condition
        crul_obj.take!(comment) if crul_obj.editor != Reactor::Configuration.xml_access[:username]
        # neccessary to recalculate #editor
        reload
        true
      end

      # Creates a working version of the object. Returns true on success or when
      # the object already has a working version. Returns false when:
      # @param comment [String] comment to leave for the next user
      # 1. user lacks the permissions
      # 2. other error occured
      def edit(comment = nil)
        edit!(comment)
        true
      rescue Reactor::Cm::XmlRequestError, Reactor::NotPermitted
        false
      end

      # Creates a working version of the object. Returns true on success or when
      # the object already has a working version. Raises exceptions
      # @param comment [String] comment to leave for the next user
      # @raise [Reactor::NotPermitted] current user lacks required permissions
      def edit!(comment = nil)
        crul_obj.edit!(comment) unless really_edited?
        reload
        true
      end

      # Returns true, if the object has any links pointing to it.
      # @raise [Reactor::Cm::XmlRequestError] generic error occoured
      def has_super_links?
        crul_obj.get("hasSuperLinks") == "1"
      end

      # Return an array of RailsConnector::AbstractObj that contain a link
      # to this file.
      # @raise [Reactor::Cm::XmlRequestError] generic error occoured
      def super_objects
        RailsConnector::AbstractObj.where(obj_id: crul_obj.get("superObjects")).to_a
      end

      # Returns true if this object hasn't been saved yet -- that is, a record
      # for the object doesn't exist in the data store yet; otherwise, returns false.
      def new_record?
        # !destroyed? && (self.id.nil? || !self.class.exists?(self.id))
        !destroyed? && (id.nil? || path.blank?)
      end

      # Stolen from Rails 3.
      # Returns if the record is persisted, i.e. stored in database (it's not a new
      # record and it was not destroyed.)
      # @note Code should not be changed without large modifications to the module.
      def persisted?
        !(new_record? || destroyed?)
      end

      # Returns true if this object has been destroyed, otherwise returns false.
      def destroyed?
        @destroyed == true
      end

      # @private
      def readonly? #:nodoc:
        # No, RailsConnector. I will not be shut-up!
        false
      end

      # Deletes the object from the CM. No callbacks are executed. Though exceptions
      # can be raised. Freezes the object.
      def delete
        crul_obj_delete if persisted?
        @destroyed = true
        freeze
      end

      # Removes the object from the CM. Runs all the callbacks. Can raise exception.
      # Freezes the object.
      def destroy
        run_callbacks(:destroy) do
          delete
        end
      end

      # Reloads object attributes. Invalidates caches. Does not call
      # any other reload methods (neither from RailsConnector nor from ActiveRecord)
      # but tries to mimmic their behaviour.
      def reload(options = nil)
        RailsConnector::AbstractObj.uncached do
          # super # Throws RecordNotFound when changing obj_class
          # AR reload
          clear_aggregation_cache
          clear_association_cache
          fresh_object = RailsConnector::AbstractObj.find(id, options)
          @attributes = fresh_object.instance_variable_get("@attributes")
          @attributes_cache = {}
          # RC reload
          @attr_values = nil
          @attr_defs = nil
          @attr_dict = nil
          @obj_class_definition = nil
          @object_with_meta_data = nil
          # meta reload
          @editor = nil
          @object_with_meta_data = nil
          self
        end
      end

      # Resolves references in any of the html fields. Returns true on success,
      # or false when:
      # 1. user lacks the permissions
      # 2. generic error occoured
      def resolve_refs
        resolve_refs!
        true
      rescue Reactor::Cm::XmlRequestError, Reactor::NotPermitted
        false
      end

      # Resolves references in any of the html fields. Returns true on success,
      # raises exceptions.
      # @raise [Reactor::NotPermitted] current user lacks required permissions
      def resolve_refs!
        crul_obj.resolve_refs!
        true
      end

      # It should excactly match ActiveRecord::Base.new in it's behavior
      # @see ActiveRecord::Base.new
      def initialize(attributes = nil, _options = {})
        if true || !self.class.send(:attribute_methods_overriden?)
          ignored_attributes = ignore_attributes(attributes)
          # supress block hijacking!
          super(attributes) {}
          load_ignored_attributes(ignored_attributes)
          yield self if block_given?
        else
          # TODO
          # here we get 'ActiveRecord::AssociationTypeMismatch'
          super(attributes)
        end
      end

      def really_edited?
        # check if really edited with curl request
        crul_obj.edited?
      end

      def edited_or_committed?
        really_edited? || committed?
      end

      # Returns an array of errors
      def reasons_for_incomplete_state
        crul_obj.get("reasonsForIncompleteState") || []
      end

      protected

      def prevent_resolve_refs
        @prevent_resolve_refs = true
      end

      def prevent_resolve_refs?
        @prevent_resolve_refs == true
      end

      def sanitize_name
        return unless name.present?

        sanitized_name = self.class.send(:sanitize_name, name)
        self.name = sanitized_name if sanitized_name != name
      end

      def crul_attributes_set?
        !crul_attributes.empty? || uploaded?
      end

      def crul_links_changed?
        !changed_linklists.empty?
      end

      def changed_linklists
        custom_attrs =
          singleton_class.send(:instance_variable_get, "@_o_allowed_attrs") ||
          self.class.send(:instance_variable_get, "@_o_allowed_attrs") ||
          []

        custom_attrs.select do |attr|
          send(:attribute_type, attr) == :linklist && send(:[], attr.to_sym).try(:changed?)
        end
      end

      def crul_attributes
        @__crul_attributes || {}
      end

      def crul_obj
        @crul_obj ||= Reactor::Cm::Obj.load(obj_id)
      end

      def crul_obj_delete
        crul_obj.delete!
      end

      def crul_obj_save
        attrs, = crul_attributes.partition do |field, (_value, _options)|
          send(:attribute_type, field) != :linklist
        end
        linklists = changed_linklists

        new_links = {}.tap do |result|
          linklists.map do |field|
            result[field] = Reactor::Attributes::LinkListFromAccessor.new(self, field).call.map do |l|
              { link_id: l.id, title: l.title, destination_url: (l.internal? ? l.destination_object.path : l.url), target: l.target }
            end
          end
        end

        links_modified = !linklists.empty?

        crul_obj.composite_save(attrs, [], [], [], links_modified) do |_attrs, links_to_add, links_to_remove, links_to_set|
          links_to_add.clear
          links_to_remove.clear
          links_to_set.clear

          copy = RailsConnector::BasicObj.uncached { RailsConnector::BasicObj.find(id) }

          linklists.each do |linklist|
            original_link_ids = Reactor::Attributes::LinkListFromAttrValues.new(copy, linklist).call.map(&:id)
            i = 0
            common = [original_link_ids.length,
                      new_links[linklist].length].min

            # replace existing links
            while i < common
              link = new_links[linklist][i]
              link[:link_id] = link_id = original_link_ids[i]

              links_to_set << [link_id, link]
              i += 1
            end

            # add appended links
            while i < new_links[linklist].length
              link = new_links[linklist][i]

              links_to_add << [linklist, link]
              i += 1
            end

            # remove trailing links
            while i < original_link_ids.length
              links_to_remove << original_link_ids[i]
              i += 1
            end
          end
        end
        self.class.connection.clear_query_cache
      end

      private

      # TODO: test it & make it public
      # Copy an Obj to another tree, returnes ID of the new Object
      # @param [String, Obj, Integer] new_parent path, id, or instance of target where to copy
      # @param [true, false] recursive set to true to also copy the underlying subtree
      # @param [String] new_name gives the object new name
      def copy(new_parent, recursive = false, new_name = nil)
        self.id = crul_obj.copy(RailsConnector::AbstractObj.path_from_anything(new_parent), recursive, new_name)
        # self.reload
        resolve_refs # ?
        id
      end

      def trim_crul_attributes
        crul_attributes.delete_if { |attr, _options| %i(name objClass).include?(attr) }
      end

      def crul_obj_create(name, parent, klass)
        @crul_obj = Reactor::Cm::Obj.create(name, parent, klass)
      end

      # TODO: depends on rails version
      def create
        run_callbacks(:create) do
          c_name = name
          c_parent = self.class.path_from_anything(parent_obj_id)
          c_objcl = obj_class
          crul_obj_create(c_name, c_parent, c_objcl)
          self.id = @crul_obj.obj_id
          crul_obj_save if crul_attributes_set? || crul_links_changed?
          reload # ?
          changes_applied
          id
        end
      end

      alias_method :_create_record, :create

      def update(_attribute_names = attribute_names)
        run_callbacks(:update) do
          crul_obj_save if crul_attributes_set? || crul_links_changed?
          reload
          changes_applied
          id
        end
      end

      alias_method :_update_record, :update

      def ignore_attributes(attributes)
        return {} if attributes.nil?

        obj_class = attributes.delete(:obj_class)
        parent    = attributes.delete(:parent)
        { obj_class: obj_class, parent: parent }
      end

      def load_ignored_attributes(attributes)
        return if attributes.nil?

        set_parent(attributes[:parent]) if attributes[:parent].present?
        set_obj_class(attributes[:obj_class]) if attributes[:obj_class].present?
      end

      def set_parent(parent_something)
        parent_obj = self.class.obj_from_anything(parent_something)
        self.parent_obj_id = parent_obj.id
        crul_set(:parent, parent_obj.path, {}) if persisted?
      end

      def set_obj_class(obj_class)
        self.obj_class = obj_class
      end

      # disables active record transactions
      def with_transaction_returning_status
        yield
      end

      # disables active record transactions
      def rollback_active_record_state!
        yield
      end
    end
    module ClassMethods
      def sanitize_name(old_name)
        if Reactor::Configuration.sanitize_obj_name
          character_map = { "ä" => "ae", "ö" => "oe", "ü" => "ue", "ß" => "ss", "Ä" => "Ae", "Ö" => "Oe", "Ü" => "Ue" }
          old_name.gsub(/[^-$a-zA-Z0-9]/) { |char| character_map[char] || "_" }
                  .gsub(/__+/, "_")
                  .gsub(/^_+/, "")
                  .gsub(/_+$/, "")

        else
          old_name
        end
      end

      # Convenience method: it is equivalent to following call chain:
      #
      #     i = create(attributes)
      #     i.upload(data_or_io, extension)
      #     i.save!
      #     i
      #
      # Use it like this:
      #
      #     image = Image.upload(File.open('image.jpg'), 'ext', :name => 'image', :parent => '/')
      #
      def upload(data_or_io, extension, attributes = {})
        # Try to guess the object name from filename, if it's missing
        if data_or_io.respond_to?(:path) && !attributes.key?(:name)
          attributes[:name] = sanitize_name(File.basename(data_or_io.path, File.extname(data_or_io.path)))
        end

        instance = create!(attributes) # do |instance|
        instance.upload(data_or_io, extension)
        instance.save!
        # end
        instance
      end

      protected

      def attribute_methods_overriden?
        name != "RailsConnector::BasicObj"
      end
    end
  end
end
