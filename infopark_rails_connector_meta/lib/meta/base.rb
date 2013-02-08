# -*- encoding : utf-8 -*-
require 'meta/eager_loader'

module RailsConnector

  module Meta

    # This method is an equivalent of Rails.logger.silence, which has been deprecated
    def self.hello_im_rails_and_im_retarted_so_please_be_patient(&block)
      begin
        old_logger_level, Rails.logger.level = Rails.logger.level, Logger::ERROR
        yield self
      ensure
        Rails.logger.level = old_logger_level
      end
    end

    def self.included(base) #:nodoc:
      #  Class enhancements
      base.extend(ClassMethods)
    end

    # The RailsConnector::ObjClass object for this file format.
    # This will always return a proper object, even if no custom
    # Ruby class exists.
    def obj_class_definition
      @obj_class_definition ||= RailsConnector::Meta::EagerLoader.instance.obj_class(self.obj_class)
    end
    alias_method :obj_class_def, :obj_class_definition

    # Returns true, if there is a custom Ruby class defined for the object
    # or false, if it is represented by RailsConnector::Obj
    def has_custom_ruby_class?
      self.class.is_custom_ruby_class?
    end

    # Returns the custom attributes in the form of a Hash.
    def custom_attributes
      self.obj_class_definition.custom_attributes
    end

    # Returns true, if the file format has an attribute of the given name.
    def custom_attribute?(attr)
      self.obj_class_definition.custom_attribute?(attr)
    end

    # Returns an Array of String of all mandatory attributes, no mather if it's
    # custom or built-in. Built-in attributes are underscored (valid_from,
    # not validFrom).
    # Possible +options+ are:
    # <tt>:only_custom_attributes</tt>:: Return only custom attributes, omit
    # built-in attributes like content_type or valid_from.
    def mandatory_attribute_names(options = {})
      self.obj_class_definition.mandatory_attribute_names(options)
    end

    # Returns true, if the file format has an mandatory attribute of the given name.
    def mandatory_attribute?(attr)
      self.obj_class_definition.mandatory_attribute?(attr)
    end

    # Returns the version of this object. This number is increased every time
    # this object is released.
    def version
      load_meta_details
      @object_with_meta_data.version.presence.to_i || 0
    end

    # Returns the time of the reminder, if it is set.
    def reminder_from
      load_meta_details
      @object_with_meta_data.reminder_from.presence &&
          ::RailsConnector::DateAttribute.parse(@object_with_meta_data.reminder_from)
    end

    # Returns the reminder comment, if a reminder is set.
    def reminder_comment
      load_meta_details
      @object_with_meta_data.reminder_comment
    end

    # Return the name of the workflow, that is assigned to this object.
    def workflow_name
      load_meta_details
      @object_with_meta_data.workflow_name
    end

    # Return the current editor as a String. If there is no edited content,
    # which is always the case in live mode, an empty String is returned.
    # The 'contents' table is queried for this information.
    def editor
      return @editor if @editor

      load_meta_details

      content_id = if self.edited?
        @object_with_meta_data.edited_content_id
      else
        @object_with_meta_data.released_cont_id
      end

      if content_id
        content = RailsConnector::Content.find(content_id)
        @editor = content.editor
      else
        @editor = ''
      end
    end

    private

    # Load the objects details from the `objects' tables.
    def load_meta_details #:nodoc:
      return if @object_with_meta_data

      @object_with_meta_data = RailsConnector::ObjectWithMetaData.find(self.id)

      # reset depending instance variables
      @editor = nil
    end


    # the methods in this module will become class methods
    module ClassMethods

      # The RailsConnector::ObjClass object for this file format.
      # This will only return a proper object if a custom Ruby class exists
      # and will throw a RuntimeError otherwise.
      def obj_class_definition
        raise "Obtaining the obj_class_definition of an Obj without custom Ruby class " \
                  "is logically impossible." unless is_custom_ruby_class?
        # @obj_class_definition ||= RailsConnector::ObjClass.find_by_name(self.name)
        @obj_class_definition ||= RailsConnector::Meta::EagerLoader.instance.obj_class(self.name)
      end
      alias_method :obj_class_def, :obj_class_definition

      # RailsConnector::Obj returns false, everything else true.
      def is_custom_ruby_class?
        self != RailsConnector::Obj
      end

    end

  end

end
