require "reactor/attributes/date_serializer"
require "reactor/attributes/html_serializer"
require "reactor/attributes/link_list_serializer"

require "reactor/attributes/link_list_extender"

require "singleton"

module Reactor
  # This module provides support for ActiveRecord like attribute setting, plus additional
  # #set method, which is equivalent to the setters.
  #
  # Date attributes are converted to correct format, when passed as Time-like objects.
  # Links within HTML attributes are scanned and are converted if they point to local objects,
  # so that the CM stores them as internal links.
  #
  # @note date attributes accept strings as values, and tries to parse them with Time.parse (unless they are in ISO format)
  # @note link recognition works only on relative urls. All absolute urls are recognized as external links
  module Attributes
    module Base
      def self.included(base)
        base.extend(ClassMethods)
        Reactor::Attributes::LinkListExtender.extend_linklist!
      end

      def valid_from=(value)
        set(:valid_from, value)
      end

      def valid_until=(value)
        set(:valid_until, value)
      end

      def obj_class=(value)
        set(:obj_class, value)
      end

      def permalink=(value)
        set(:permalink, value)
      end

      def name=(value)
        set(:name, value)
      end

      def body=(value)
        set(:body, value)
      end

      def blob
        attr_dict.send :blob if attr_dict.respond_to?(:blob)
      end

      def blob=(value)
        set(:blob, value)
      end

      def title=(value)
        set(:title, value)
      end

      def channels=(value)
        set(:channels, value)
      end

      def channels
        self[:channels] || []
      end

      def suppress_export=(value)
        set(:suppress_export, value)
      end

      def _read_attribute(key)
        if active_record_attr?(key)
          super
        else
          __send__(key)
        end
      end

      # Sets given attribute, to given value. Converts values if neccessary
      # @see [Reactor::Attributes]
      # @note options are passed to underlying xml interface, but as of now have no effect
      def set(key, value, options = {})
        key = key.to_sym
        raise TypeError, "can't modify frozen object" if frozen?
        raise ArgumentError, "Unknown attribute #{key} for #{self.class} #{path}" unless allowed_attr?(key)

        attribute_will_change!(key.to_s)

        attribute = key_to_attr(key)

        formated_value = serialize_value(key, value)
        crul_set(attribute, formated_value, options)

        if active_record_attr?(key)
          formated_value = to_time_in_zone(formated_value) if attribute_type(key) == :date
        else
          rails_connector_set(key, formated_value)
        end
        @attributes.write_from_user(key.to_s, formated_value)
        __send__(key)
      end

      # Uploads a file/string into a CM. Requires call to save afterwards(!)
      # @param [String, IO] data_or_io
      # @param [String] extension file extension
      # @note Uploaded file is loaded into memory, so try not to do anything silly (like uploading 1GB of data)
      def upload(data_or_io, extension)
        self.uploaded = true
        crul_obj.upload(data_or_io, extension)
      end

      def uploaded?
        uploaded == true
      end

      # @deprecated
      def set_link(key, id_or_path_or_cms_obj)
        target_path = case id_or_path_or_cms_obj
                      when Integer then Obj.find(id_or_path_or_cms_obj).path
                      when String then id_or_path_or_cms_obj
                      when Obj then id_or_path_or_cms_obj.path
                      else raise ArgumentError, "Link target must Integer, String or Obj, but was #{id_or_path_or_cms_obj.class}."
        end

        edit!
        @force_resolve_refs = true
        crul_obj.set_link(key, target_path.to_s)
      end

      def reload_attributes(new_obj_class = nil)
        new_obj_class ||= obj_class
        RailsConnector::Meta::EagerLoader.instance.forget_obj_class(new_obj_class)
        Reactor::AttributeHandlers.reinstall_attributes(singleton_class, new_obj_class)
        self.class.reinitialize_attributes
      end

      protected

      attr_accessor :uploaded

      def builtin_attributes
        @builtin_attrs ||= (active_record_attributes + Reactor::Cm::Obj::PREDEFINED_ATTRS).map { |item| item.to_s.underscore.to_sym }
      end

      def builtin_attr?(attr)
        builtin_attributes.include?(attr)
      end

      def active_record_attributes
        @active_record_attrs ||= self.class.columns.map(&:name)
      end

      def active_record_attr?(attr)
        active_record_attributes.include?(attr.to_s)
      end

      def allowed_attr?(attr)
        # TODO: rebuild with current attribute_names method
        return true if builtin_attr?(attr)

        custom_attrs =
          singleton_class.send(:instance_variable_get, "@_o_allowed_attrs") ||
          self.class.send(:instance_variable_get, "@_o_allowed_attrs") ||
          []

        custom_attrs.include?(key_to_attr(attr))
      end

      def key_to_attr(key)
        @__attribute_map ||= {
          body: :blob,
          valid_until: :validUntil,
          valid_from: :validFrom,
          content_type: :contentType,
          suppress_export: :suppressExport,
          obj_class: :objClass
        }

        key = key.to_sym
        key = @__attribute_map[key] if @__attribute_map.key?(key)
        key
      end

      def serialize_value(key, value)
        case attribute_type(key)
        when :html
          HTMLSerializer.new(key, value).serialize
        when :date
          DateSerializer.new(key, value).serialize
        when :linklist
          LinkListSerializer.new(key, value).serialize
        else
          value
        end
      end

      def rails_connector_set(field, value)
        field = field.to_sym
        field = :blob if field == :body
        case attribute_type(field)
        when :linklist
          send(:attr_dict).instance_variable_get("@attr_cache")[field] = value
          send(:attr_dict).send(:blob_dict)[field] = :special_linklist_handling_is_broken
        when :date
          send(:attr_dict).instance_variable_get("@attr_cache")[field] = to_time_in_zone(value)
          send(:attr_dict).send(:blob_dict)[field] = value
        else
          send(:attr_dict).instance_variable_get("@attr_cache")[field] = nil
          send(:attr_dict).send(:blob_dict)[field] = value
        end
      end

      def to_time_in_zone(value)
        return nil if value.blank?

        ActiveSupport::TimeZone["UTC"].parse(value).in_time_zone
      end

      def cached_value?(attr, _value)
        attribute_type(attr) == :linklist
      end

      # Lazily sets values for crul interface. May be removed in later versions
      def crul_set(field, value, options)
        @__crul_attributes ||= {}
        @__crul_attributes[field.to_sym] = [value, options]
      end

      private

      def path=(*args)
        super
      end

      def attribute_type(attr)
        return :html if %i(body blob).include?(attr.to_sym)
        return :date if %i(valid_from valid_until last_changed).include?(attr.to_sym)
        return :string if %i(name title obj_class permalink suppress_export).include?(attr.to_sym)
        return :multienum if [:channels].include?(attr.to_sym)

        custom_attr = obj_class_def.try(:custom_attributes).try(:[], attr.to_s)
        raise TypeError, "obj_class_def is nil for: #{obj_class}" if obj_class_def.nil?

        # FIXME: this should blow up on error
        # raise TypeError, "Unable to determine type of attribute: #{attr}" if custom_attr.nil?
        custom_attr ||= { "attribute_type" => :string }
        custom_attr["attribute_type"].to_sym
      end
    end
    module ClassMethods
      def inherited(subclass)
        super(subclass) # if you remove this line, y'll get TypeError: can't dup NilClass at some point

        # t2 = Time.now
        Reactor::AttributeHandlers.install_attributes(subclass)
        # Rails.logger.debug "Installing dynamic module for #{subclass.name} took #{Time.now - t2}"
        subclass
      end

      def __cms_attributes(obj_class)
        obj_class_def = RailsConnector::Meta::EagerLoader.instance.obj_class(obj_class) # RailsConnector::ObjClass.where(:obj_class_name => obj_class).first
        obj_class_def ? obj_class_def.custom_attributes : {}
      end

      def __mandatory_cms_attributes(obj_class)
        obj_class_def = RailsConnector::Meta::EagerLoader.instance.obj_class(obj_class) # RailsConnector::ObjClass.where(:obj_class_name => obj_class).first
        obj_class_def ? obj_class_def.mandatory_attribute_names(only_custom_attributes: true) : []
      end

      def reload_attributes(new_obj_class = nil)
        new_obj_class ||= name
        if new_obj_class.nil?
          raise ArgumentError, "Cannot reload attributes because obj_class is unknown, provide one as a parameter"
        end

        RailsConnector::Meta::EagerLoader.instance.forget_obj_class(new_obj_class)
        Reactor::AttributeHandlers.reinstall_attributes(self, new_obj_class)
        reinitialize_attributes
      end
    end
  end
end
