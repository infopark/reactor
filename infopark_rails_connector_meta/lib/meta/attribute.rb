module RailsConnector

  # The methods date?, enum?, html?, linklist?, markdown?, multienum?, string? and
  # text? are created by meta programming have no documentation of their own.
  # Warning: Dependent on the setup of your DB replication, most tables
  # with meta information will not be available on your live system!
  class Attribute < RailsConnector::InfoparkBase

    # The possible types of an attribute.
    TYPES = %w{date enum html linklist markdown multienum string text}

    self.primary_key = :attribute_id

    has_and_belongs_to_many :obj_class_definitions, :class_name => '::RailsConnector::ObjClass',
        :join_table => "#{table_name_prefix}obj_class_attrs"

    alias_method :obj_class_defs, :obj_class_definitions
    alias_attribute :name, :attribute_name

    # The (human readable) title.
    def title(language = :de)
      load_blob_data
      @blob_data['titles'].presence && @blob_data['titles'][language.to_s]
    end

    # The description of the attribute.
    def help_text(language = :de)
      load_blob_data
      @blob_data['helpTexts'].presence && @blob_data['helpTexts'][language.to_s]
    end

    # Searchable in Content Manager.
    def searchable_in_cm?
      load_blob_data
      @blob_data['isSearchableInCM'].to_i != 0
    end

    # Returns the possible values if attribute is of type `enum' or `multienum'.
    def values
      load_blob_data
      @blob_data['values']
    end

    def max_size
      load_blob_data
      @blob_data["maxSize"]
    end

    def min_size
      load_blob_data
      @blob_data["minSize"]
    end

    TYPES.each do |type|
      self.class_eval <<EOM, __FILE__, __LINE__ + 1
        def #{type}?
          self.attribute_type == "#{type}"
        end
EOM
    end

    # Convenience method for find_by_attribute_name
    def self.find_by_name(*args)
      self.find_by_attribute_name(*args)
    end

    # Returns the blob as a JSON object.
    def self.read_blob_data(name) #:nodoc:
      blob = RailsConnector::Meta.hello_im_rails_and_im_retarted_so_please_be_patient do            # these queries really pollute our logs!
        blob_name = if RailsConnector::BlobMapping.exists?
          RailsConnector::BlobMapping.get_fingerprint("#{name}.jsonAttributeDict")
        else
          "#{name}.jsonAttributeDict"
        end

        RailsConnector::Blob.find_without_excluded_blob_data(blob_name)
      end

      return {} unless blob && blob.blob_data?

      JSON.parse(blob.blob_data)
    end

    private

    # load attribute details from blob
    def load_blob_data #:nodoc:
      @blob_data ||= self.class.read_blob_data(self.attribute_name)
    end

  end

end