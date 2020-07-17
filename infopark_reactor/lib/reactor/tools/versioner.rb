require "base64"
require "yaml"
require "singleton"

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
            xml.where_key_tag!(base_name, "name", name)
            xml.get_key_tag!(base_name, "name")
          end
          response = request.execute!
          response.ok?
        rescue StandardError
          false
        end
      end

      def load
        create unless exists?
        request = Reactor::Cm::XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, "name", name)
          xml.get_key_tag!(base_name, "recordSetCallback")
        end
        response = request.execute!
        base64 = response.xpath("//recordSetCallback").text.to_s
        yaml = Base64.decode64(base64)
        data = YAML.load(yaml)
        return [] if data.nil? || (data == false)

        data.to_a
      end

      def store(data)
        create unless exists?
        yaml = data.to_yaml
        base64 = Base64.encode64(yaml).delete("\n").delete("\r")
        content = "#" + base64
        request = Reactor::Cm::XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, "name", name)
          xml.set_key_tag!(base_name, "recordSetCallback", content)
        end
        response = request.execute!
        response.ok?
      end

      def create
        request = Reactor::Cm::XmlRequest.prepare do |xml|
          xml.create_tag!(base_name) do
            xml.tag!("name") do
              xml.text!(name)
            end
            xml.tag!("objType") do
              xml.text!("document")
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
      !@versions.delete(version.to_s).nil?
    end

    attr_reader :versions

    def current_version
      current = @versions.max
      return 0 if current.nil?

      current
    end
  end
end
