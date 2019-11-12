# -*- encoding : utf-8 -*-
require 'singleton'
require 'set'

module RailsConnector
  module Meta
    class EagerLoader
      include Singleton
      attr_reader :obj_classes

      def initialize
        # Rails.logger.debug "EagerLoader: I am eager to start working"
        @obj_classes = {}
        RailsConnector::ObjClass.includes(:custom_attributes_raw).all.each do |obj_class|
          @obj_classes[obj_class.name] = obj_class
        end
        preload_attribute_blobs
      end

      def obj_class(name)
        name = name.to_s
        if !@obj_classes.fetch(name, nil).nil?
          @obj_classes[name]
        else
          # TODO: preload_attribute_blobs for obj_class
          @obj_classes[name] ||= RailsConnector::ObjClass.find_by_obj_class_name(name)
        end
      end

      def forget_obj_class(name)
        @obj_classes.delete(name.to_s)
      end

      protected
      def preload_attribute_blobs
        attribute_names = Set.new
        @obj_classes.each do |_, obj_class|
          obj_class.custom_attributes.each do |attribute_name, _|
            attribute_names << attribute_name
          end
        end

        blob_names               = attribute_names.map {|attribute_name| "#{attribute_name}.jsonAttributeDict" }
        fingerprint_map          = RailsConnector::BlobMapping.get_fingerprint_map(blob_names)
        blob_fingerprints        = fingerprint_map.values
        # NOTE: this is correct!
        blobs                    = RailsConnector::Blob.where(:blob_name => blob_fingerprints).to_a
        blob_map                 = Hash[blobs.map {|b| [b.blob_name, b]}]

        @obj_classes.each do |_, obj_class|
          obj_class.custom_attributes.each do |_, attribute|
            blob_name   = "#{attribute.name}.jsonAttributeDict"
            fingerprint = fingerprint_map[blob_name]
            blob        = blob_map[fingerprint]

            next unless blob && blob.blob_data?
            attribute.instance_variable_set(:@blob_data, ::JSON.parse(blob.blob_data))
          end
        end
      end
    end
  end
end
