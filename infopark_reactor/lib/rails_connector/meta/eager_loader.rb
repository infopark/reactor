# -*- encoding : utf-8 -*-
require 'singleton'

module RailsConnector
  module Meta
    class EagerLoader
      include Singleton
      attr_reader :obj_classes

      def initialize
        # Rails.logger.debug "EagerLoader: I am eager to start working"
        @obj_classes = {}
        # Rails 3.1 contains a bug that screws attribute loading
        # attributes are set to assigned classes
        if ::Rails::VERSION::MAJOR == 3 && ::Rails::VERSION::MINOR == 1
          RailsConnector::ObjClass.all.each do |obj_class|
            obj_class.custom_attributes
            @obj_classes[obj_class.name] = obj_class
          end
        else
          RailsConnector::ObjClass.includes(:custom_attributes_raw).all.each do |obj_class|
            @obj_classes[obj_class.name] = obj_class
          end
        end
      end

      def obj_class(name)
        name = name.to_s
        if !@obj_classes.fetch(name, nil).nil?
          # puts "EagerLoader: I've already loaded it: #{name}"
          @obj_classes[name]
        else
          # puts "EagerLoader: NO HAVE: #{name}"
          @obj_classes[name] ||= RailsConnector::ObjClass.find_by_obj_class_name(name)
        end
      end

      def forget_obj_class(name)
        @obj_classes.delete(name.to_s)
      end
    end
  end
end
