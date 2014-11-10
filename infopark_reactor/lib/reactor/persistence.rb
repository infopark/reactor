# -*- encoding : utf-8 -*-
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
      def release(comment=nil)
        return release!(comment)
      rescue Reactor::Cm::XmlRequestError, ActiveRecord::RecordInvalid, Reactor::NotPermitted, Reactor::AlreadyReleased
        return false
      end

      # Removes the working version of the object,
      # if it exists
      # @param comment [String] comment to leave for the next user
      # @return [true]
      def revert(comment=nil)
        return revert!(comment)
      end

      # Removes the working version of the object,
      # if it exists
      # @param comment [String] comment to leave for the next user
      # @return [true]
      # @note There is no difference between #revert and #revert!
      def revert!(comment=nil)
        crul_obj.revert!(comment)
        reload
        return true
      end

      # Releases the object. Returns true on succes, can raise exceptions
      # @param comment [String] comment to leave for the next user
      # @raise [Reactor::AlreadyReleased]
      # @raise [ActiveRecord::RecordInvalid] validations failed
      # @raise [Reactor::NotPermitted] current user lacks required permissions
      def release!(comment=nil)
        run_callbacks(:release) do
          raise(Reactor::AlreadyReleased) unless self.really_edited?
          crul_obj.release!(comment)
          reload
        end
        return true
      end

      # Makes the current user the editor of the object. Returns true when
      # user is already the editor or take succeded,
      # false when one of the following occurs:
      # 1. user lacks the permissions
      # 2. the object has not beed edited
      # 3. other error occured
      # @param comment [String] comment to leave for the next user
      def take(comment=nil)
        take!(comment)
        return true
      rescue Reactor::Cm::XmlRequestError, Reactor::NotPermitted, Reactor::NoWorkingVersion
        return false
      end

      # Makes the current user the editor of the object. Returns true when
      # user is already the editor or take succeded. Raises exceptions
      # @param comment [String] comment to leave for the next user
      # @raise [Reactor::NoWorkingVersion] there is no working version of the object
      # @raise [Reactor::NotPermitted] current user lacks required permissions
      def take!(comment=nil)
        raise(Reactor::NoWorkingVersion) unless self.really_edited?
        # TODO: refactor the if condition
        crul_obj.take!(comment) if (crul_obj.editor != Reactor::Configuration::xml_access[:username])
        # neccessary to recalculate #editor
        reload
        return true
      end

      # Creates a working version of the object. Returns true on success or when
      # the object already has a working version. Returns false when:
      # @param comment [String] comment to leave for the next user
      # 1. user lacks the permissions
      # 2. other error occured
      def edit(comment=nil)
        edit!(comment)
        return true
      rescue Reactor::Cm::XmlRequestError, Reactor::NotPermitted
        return false
      end

      # Creates a working version of the object. Returns true on success or when
      # the object already has a working version. Raises exceptions
      # @param comment [String] comment to leave for the next user
      # @raise [Reactor::NotPermitted] current user lacks required permissions
      def edit!(comment=nil)
        crul_obj.edit!(comment) unless self.really_edited?
        reload
        return true
      end

      # Returns true, if the object has any links pointing to it.
      # @raise [Reactor::Cm::XmlRequestError] generic error occoured
      def has_super_links?
        crul_obj.get('hasSuperLinks') == '1'
      end

      # Return an array of RailsConnector::AbstractObj that contain a link
      # to this file.
      # @raise [Reactor::Cm::XmlRequestError] generic error occoured
      def super_objects
        RailsConnector::AbstractObj.where(:obj_id => crul_obj.get('superObjects')).to_a
      end

      # Returns true if this object hasn't been saved yet -- that is, a record
      # for the object doesn't exist in the data store yet; otherwise, returns false.
      def new_record?
        #!destroyed? && (self.id.nil? || !self.class.exists?(self.id))
        !destroyed? && (self.id.nil? || self.path.blank?)
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
          self.delete
        end
      end

      # Reloads object attributes. Invalidates caches. Does not call
      # any other reload methods (neither from RailsConnector nor from ActiveRecord)
      # but tries to mimmic their behaviour.
      def reload(options = nil)
        RailsConnector::AbstractObj.uncached do
          #super # Throws RecordNotFound when changing obj_class
          # AR reload
          clear_aggregation_cache
          clear_association_cache
          fresh_object = RailsConnector::AbstractObj.find(self.id, options)
          @attributes = fresh_object.instance_variable_get('@attributes')
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
        return true
      rescue Reactor::Cm::XmlRequestError, Reactor::NotPermitted
        return false
      end

      # Resolves references in any of the html fields. Returns true on success,
      # raises exceptions.
      # @raise [Reactor::NotPermitted] current user lacks required permissions
      def resolve_refs!
        crul_obj.resolve_refs!
        return true
      end

      if Reactor.rails3_0?
        # It should excactly match ActiveRecord::Base.new in it's behavior
        # @see ActiveRecord::Base.new
        def initialize(attributes = nil, &block)
          if true ||  !self.class.send(:attribute_methods_overriden?) # FIXME !!!!
            ignored_attributes = ignore_attributes(attributes)
            # supress block hijacking!
            super(attributes) {}
            load_ignored_attributes(ignored_attributes)
            yield self if block_given?
          else
            super(attributes)
          end
        end
      elsif Reactor.rails3_1? || Reactor.rails3_2? || Reactor.rails4_0?
        # It should excactly match ActiveRecord::Base.new in it's behavior
        # @see ActiveRecord::Base.new
        def initialize(attributes = nil, options={}, &block)
          if true ||  !self.class.send(:attribute_methods_overriden?) #FIXME !!!
            ignored_attributes = ignore_attributes(attributes)
            # supress block hijacking!
            super(attributes, options) {}
            load_ignored_attributes(ignored_attributes)
            yield self if block_given?
          else
            super(attributes, options)
          end
        end
      else
        raise RuntimeError, "Unsupported Rails version!"
      end


=begin
      # @see [ActiveRecord::Persistence#update_attributes]
      def update_attributes(attributes, options={})
        attributes.each do |attr, value|
          self.send(:"#{attr}=", value)
        end
        self.save
      end

      # @see [ActiveRecord::Persistence#update_attributes!]
      def update_attributes!(attributes, options={})
        attributes.each do |attr, value|
          self.send(:"#{attr}=", value)
        end
        self.save!
      end
=end

      # Equivalent to Obj#edited?
      def really_edited?
        self.edited?
      end

      # Returns an array of errors
      def reasons_for_incomplete_state
        crul_obj.get('reasonsForIncompleteState') || []
      end

      protected
      def prevent_resolve_refs
        @prevent_resolve_refs = true
      end

      def prevent_resolve_refs?
        @prevent_resolve_refs == true
      end

      def sanitize_name
        self.name = self.class.send(:sanitize_name, self.name)
      end

      def crul_attributes_set?
        !crul_attributes.empty? || uploaded?
      end

      def crul_links_changed?
        !changed_linklists.empty?
      end

      def changed_linklists
        (self.class.send(:instance_variable_get, '@_o_allowed_attrs') || []).select do |attr|
          self.send(:attribute_type, attr) == :linklist && self.send(:[],attr.to_sym).try(:changed?)
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
        attrs, _ = crul_attributes.partition do |field, (value, options)|
          self.send(:attribute_type, field) != :linklist
        end
        linklists = changed_linklists

        new_links = {}.tap do |result|
          linklists.map do |field|
            result[field] = self.__read_link(field).map do |l|
              {:link_id => l.id, :title => l.title, :destination_url => (l.internal? ? l.destination_object.path : l.url)} 
            end
          end
        end

        links_modified = !linklists.empty?

        crul_obj.composite_save(attrs, [], [], [], links_modified) do |attrs, links_to_add, links_to_remove, links_to_set|

          links_to_add.clear
          links_to_remove.clear
          links_to_set.clear

          copy = RailsConnector::AbstractObj.find(self.id)

          linklists.each do |linklist|
            original_link_ids = copy.__read_link(linklist).original_link_ids
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
      end

      def __read_link(name)
        self[name.to_sym] || RailsConnector::LinkList.new([])
      end

      private

      # TODO: test it & make it public
      # Copy an Obj to another tree, returnes ID of the new Object
      # @param [String, Obj, Integer] new_parent path, id, or instance of target where to copy
      # @param [true, false] recursive set to true to also copy the underlying subtree
      # @param [String] new_name gives the object new name
      def copy(new_parent, recursive = false, new_name = nil)
        self.id = crul_obj.copy(RailsConnector::AbstractObj.path_from_anything(new_parent), recursive, new_name)
        #self.reload
        resolve_refs #?
        self.id
      end

      def trim_crul_attributes
        crul_attributes.delete_if {|attr, options| [:name, :objClass].include?(attr) }
      end

      def crul_obj_create(name, parent, klass)
        @crul_obj = Reactor::Cm::Obj.create(name, parent, klass)
      end

      def create
        run_callbacks(:create) do
          c_name  = self.name
          c_parent= self.class.path_from_anything(self.parent_obj_id)
          c_objcl = self.obj_class
          crul_obj_create(c_name, c_parent, c_objcl)
          self.id = @crul_obj.obj_id
          crul_obj_save if crul_attributes_set? || crul_links_changed?
          self.reload # ?
          self.id
        end
      end

      if Reactor.rails4_0?
        if Reactor.rails4_0_ge6?
          alias_method :_create_record, :create
        else
          alias_method :create_record, :create
        end
      end

      def update
         run_callbacks(:update) do
           crul_obj_save if crul_attributes_set? || crul_links_changed?
           self.reload
           self.id
         end
      end

      if Reactor.rails4_0?
        if Reactor.rails4_0_ge6?
          alias_method :_update_record, :update
        else
          alias_method :update_record, :update
        end
      end

      def ignore_attributes(attributes)
        return {} if attributes.nil?

        obj_class = attributes.delete(:obj_class)
        parent    = attributes.delete(:parent)
        {:obj_class => obj_class, :parent => parent}
      end



      def load_ignored_attributes(attributes)
        return if attributes.nil?

        set_parent(attributes[:parent]) if attributes[:parent].present?
        set_obj_class(attributes[:obj_class]) if attributes[:obj_class].present?
      end

      def set_parent(parent_something)
        self.parent_obj_id = self.class.obj_id_from_anything(parent_something)
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
        character_map = {'ä' => 'ae', 'ö' => 'oe', 'ü' => 'ue', 'ß' => 'ss', 'Ä' => 'Ae', 'Ö' => 'Oe', 'Ü' => 'Ue'}
        new_name = old_name.gsub(/[^-$a-zA-Z0-9]/) {|char| character_map[char] || '_'}.
                    gsub(/__+/,'_').
                    gsub(/^_+/,'').
                    gsub(/_+$/,'')
        new_name
      end

      if Reactor.rails4_0?
        # Detect the subclass from the inheritance column of attrs. If the inheritance column value
        # is not self or a valid subclass, raises ActiveRecord::SubclassNotFound
        # If this is a StrongParameters hash, and access to inheritance_column is not permitted,
        # this will ignore the inheritance column and return nil
        def subclass_from_attrs(attrs)
          subclass_name = attrs.with_indifferent_access[inheritance_column]

          if subclass_name.present? && subclass_name != self.name
            subclass = subclass_name.safe_constantize
            
            if subclass # this if has been added
              unless descendants.include?(subclass)
                raise ActiveRecord::SubclassNotFound.new("Invalid single-table inheritance type: #{subclass_name} is not a subclass of #{name}")
              end

              subclass
            end
          end
        end

        if Reactor.rails4_0_ge6?
          alias_method :subclass_from_attributes, :subclass_from_attrs
          remove_method :subclass_from_attrs
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
      def upload(data_or_io, extension, attributes={})
        # Try to guess the object name from filename, if it's missing
        if (data_or_io.respond_to?(:path) && !attributes.key?(:name))
          attributes[:name] = sanitize_name(File.basename(data_or_io.path, File.extname(data_or_io.path)))
        end

        instance = self.create!(attributes)# do |instance|
          instance.upload(data_or_io, extension)
          instance.save!
        #end
        instance
      end

      protected
      def attribute_methods_overriden?
        self.name != 'RailsConnector::AbstractObj'
      end
    end
  end
end
