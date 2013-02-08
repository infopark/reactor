# -*- encoding : utf-8 -*-
require 'base64'
require 'yaml'
require 'singleton'

module Reactor
  # Class responsible for interfacing with version-storing mechanism
  class Versioner
    include Singleton

    # Slave class used by Versioner class to load and store migrated files
    # inside the CM. It uses separate object type named "version_store"
    # and stores data as base64'ed YAML inside recordSetCallback
    # (Versionszuweisungsfunktion).
    # Theoretically you could use any class for this purpose, but you would
    # lose the ability to set recordSetCallback for this class. Other than
    # that, it does not affect the object class in any way!
    #
    # Maybe the future version won't disrupt even this fuction.
    class Slave
      def name
        "version_store"
      end

      def base_name
        "objClass"
      end

      def exists?
        begin
          request = Reactor::Cm::XmlRequest.prepare do |xml|
            xml.where_key_tag!(base_name, 'name', name)
            xml.get_key_tag!(base_name, 'name')
          end
          response = request.execute!
          return response.ok?
        rescue
          return false
        end
      end

      def load
        create if not exists?
        request = Reactor::Cm::XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, 'name', name)
          xml.get_key_tag!(base_name, 'recordSetCallback')
        end
        response = request.execute!
        base64 = response.xpath("//recordSetCallback").text.to_s
        yaml = Base64::decode64(base64)
        data = YAML::load(yaml)
        return [] if data.nil? or data == false
        return data.to_a
      end

      def store(data)
        create if not exists?
        yaml = data.to_yaml
        base64 = Base64::encode64(yaml).gsub("\n", '').gsub("\r", '')
        content = '#' + base64
        request = Reactor::Cm::XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, 'name', name)
          xml.set_key_tag!(base_name, 'recordSetCallback', content)
        end
        response = request.execute!
        response.ok?
      end

      def create
        request = Reactor::Cm::XmlRequest.prepare do |xml|
          xml.create_tag!(base_name) do
            xml.tag!('name') do
              xml.text!(name)
            end
            xml.tag!('objType') do
              xml.text!('document')
            end
          end
        end
        response = request.execute!
        response.ok?
      end
    end

    def initialize
      @versions = []
      @backend = Slave.new
      load
    end

    def load
      @versions = @backend.load
    end

    def store
      @backend.store(@versions)
    end

    def applied?(version)
      @versions.include? version.to_s
    end

    def add(version)
      @versions << version.to_s
    end

    def remove(version)
      not @versions.delete(version.to_s).nil?
    end

    def versions
      @versions
    end

    def current_version
      current = @versions.sort.reverse.first
      return 0 if current.nil?
      return current
    end
  end
end
