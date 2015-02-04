# -*- encoding : utf-8 -*-
module RailsConnector

  # This class is used to read out the custom attributes,
  # mandatory attributes and titles of an Obj.
  # Warning: Dependent on the setup of your DB replication, most tables
  # with meta information will not be available on your live system!
  class ObjClass < RailsConnector::AbstractModel

    self.primary_key = :obj_class_id

    has_and_belongs_to_many :custom_attributes_raw, :class_name => '::RailsConnector::Attribute',
        :join_table => "#{table_name_prefix}obj_class_attrs"

    alias_attribute :name, :obj_class_name

    # Returns the title of the file format or nil, if it was not set.
    def title(language)
      self.titles[language.to_s].presence
    end

    # Returns all titles as a Hash.
    def titles
      load_blob_data
      @blob_data['titles'] || {}
    end

    def attribute_groups
      load_blob_data
      @blob_data['attributeGroups'] || []
    end

    def valid_sub_obj_classes
      load_blob_data
      @blob_data['validSubObjClasses'] || []
    end

    # returns channel feature is_activate?
    def can_create_news_items?
      load_blob_data
      @blob_data['canCreateNewsItems'].to_i != 0
    end

    def enabled?
      is_enabled == 1
    end

    # Returns the custom Ruby class or RailsConnector::AbstractObj.
    def ruby_class
      # this must be the same algorithm that the rest of the RailsConnector uses!
      RailsConnector::AbstractObj.compute_type(self.name)
    end

    # Returns true, if a custom Ruby class exists.
    def has_custom_ruby_class?
      self.ruby_class.present? && self.ruby_class != RailsConnector::AbstractObj &&
          self.ruby_class.ancestors.include?(RailsConnector::AbstractObj)
    end

    # Returns the custom attributes in the form of a Hash.
    def custom_attributes
      # return the cached data
      return @custom_attributes if @custom_attributes

      # create a Hash (with indifferent access) out of an Array of ActiveRecord objects
      @custom_attributes = self.custom_attributes_raw.map do |attr|
        {attr.attribute_name => attr}
      end.reduce(HashWithIndifferentAccess.new, &:merge)
    end

    # Returns true, if the Obj Class has an attribute of the given name.
    def custom_attribute?(attr)
      self.custom_attributes.key?(attr)
    end

    # Returns an Array of String of all mandatory attributes found for this ObjClass,
    # no matter if it is a custom or built-in attribute. Built-in attributes
    # are underscored (valid_from, not validFrom).
    # Possible +options+ are:
    # <tt>:only_custom_attributes</tt>:: Return only custom attributes, omit
    # built-in attributes like content_type or valid_from.
    def mandatory_attribute_names(options = {})
      only_custom_attributes ||= options[:only_custom_attributes] || false
      build_mandatory_attribute_arrays
      return @mandatory_custom_attributes if only_custom_attributes
      @mandatory_attributes
    end

    # Returns true, if the file format has an mandatory attribute of the given name.
    def mandatory_attribute?(attr)
      self.mandatory_attribute_names.include?(attr.to_s)
    end

    # Convenience method for find_by_obj_class_name
    def self.find_by_name(*args)
      self.find_by_obj_class_name(*args)
    end

    # Reads a whole bunch of data, where only some of it is useful
    # in a Rails application:
    # attributeGroups, availableBlobEditors, bodyTemplateName,
    # canCreateNewsItems, completionCheck, mandatoryAttributes,
    # presetAttributes, recordSetCallback, titles, validSubObjClassCheck,
    # workflowModification
    def self.read_blob_data(name) #:nodoc:
      blob = RailsConnector::Meta.hello_im_rails_and_im_retarted_so_please_be_patient do            # these queries really pollute our logs!
        blob_name = if RailsConnector::BlobMapping.exists?
          RailsConnector::BlobMapping.get_fingerprint("#{name}.jsonObjClassDict")
        else
          "#{name}.jsonObjClassDict"
        end

        RailsConnector::Blob.find_without_excluded_blob_data(blob_name)
      end

      return {} unless blob && blob.blob_data?

      JSON.parse(blob.blob_data)
    end

    private

    def load_blob_data #:nodoc:
      return if @blob_data

      @blob_data = self.class.read_blob_data(self.name)

      # reset depending instance variables
      @mandatory_custom_attributes = @mandatory_attributes = nil
    end

    def build_mandatory_attribute_arrays #:nodoc:
      return if @mandatory_attributes

      load_blob_data

      @mandatory_custom_attributes = []
      @mandatory_attributes = []
      (@blob_data['mandatoryAttributes'] || []).each do |attr|
        attr_name = attr.to_s
        if self.custom_attribute?(attr_name)
          @mandatory_custom_attributes << attr_name
        else
          # only modify built-in attributes; i.e. `validFrom` will become `valid_from`
          attr_name = attr_name.underscore
        end
        @mandatory_attributes << attr_name
      end
    end

  end

end
