# -*- encoding : utf-8 -*-
require 'reactor/cm/xml_request'
require 'reactor/cm/xml_response'
require 'reactor/cm/xml_request_error'
require 'reactor/tools/xml_attributes'
require 'reactor/tools/response_handler/xml_attribute'
require 'reactor/tools/where_query'

require 'reactor/cm/permissions'

module Reactor

  module Cm

    # The Group class can be used to work with user groups defined or known to the content manager.
    # It allows you to create, edit and delete groups, handle users and permissions and get the
    # group meta data. The Group class does not respect the user management defined under
    # "config/userManagement.xml", but is the basis for class like @EditorialGroup or @LiveGroup
    # that respect the user management.
    class Group

      include XmlAttributes
      extend WhereQuery

      class << self

        # Method returns true if a group with the given +name+ exists, false otherwise.
        def exists?(name)
          object = new(:name => name)

          begin
            object.send(:get).present?
          rescue XmlRequestError
            false
          end
        end

        # Returns all known group names as an array of strings.
        def all(match = nil)
          self.where("groupText", match)
        end

        # See @get.
        def get(name)
          object = new(:name => name)
          object.send(:get)
          object
        end

        # See @create.
        def create(attributes = {})
          object = new(attributes)
          object.send(:create)
          object
        end

      end

      include Permissions

      attribute :name, :except => [:set]
      attribute :display_title, :name => :displayTitle, :only => [:get]
      attribute :real_name, :name => :realName
      attribute :owner
      attribute :users, :type => :list

      primary_key :name

      # Returns true, if an user with the given +name+ exists, false otherwise.
      def user?(name)
        users.include?(name)
      end

      # Add the given +users+ to the current set of group users.
      def add_users!(users)
        users = users.kind_of?(Array) ? users : [users]
        users = self.users | users

        set_users(users)
      end

      # Remove the given +users+ from the current set of group users.
      def remove_users!(users)
        users = users.kind_of?(Array) ? users : [users]
        users = self.users - users

        set_users(users)
      end

      # Set the group users to the given +users+.
      def set_users!(users)
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, self.class.primary_key, self.name)
          xml.set_key_tag!(base_name, self.class.xml_attribute(:users).name, users)
        end

        request.execute!

        self.users = users
      end

      # Saves all settable instance attributes to the Content Manager.
      def save!
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, self.class.primary_key, self.name)
          xml.set_tag!(base_name) do
            self.class.attributes(:set).each do |name, xml_attribute|
              value = self.send(name)

              xml.value_tag!(xml_attribute.name, value)
            end
          end
        end

        response = request.execute!

        response.ok?
      end

      # Deletes the current group instance.
      def delete!
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, self.class.primary_key, self.name)
          xml.delete_tag!(base_name)
        end

        response = request.execute!

        response.ok?
      end

      # As it is not possible to actually rename an existing group, this method creates a new group
      # with the same attributes but a different name as the current instance and deletes the old
      # group. The method returns the new group object.
      def rename!(name)
        new_attributes =
        self.class.attributes.inject({}) do |hash, mapping|
          key, _ = mapping

          hash[key] = self.send(key)

          hash
        end

        if self.delete!
          new_attributes[:name] = name

          self.class.create(new_attributes)
        else
          false
        end
      end

      protected

      # The group base name can either be "group", "groupProxy", or "secondaryGroupProxy". Only the
      # two proxy group names take the configured user management (config/userManagement.xml) into
      # account. Use +EditorialGroup+ to work on editorial groups and +LiveGroup+ to work on live
      # groups.
      def base_name
        self.class.base_name
      end

      def self.base_name
        'group'
      end

      def initialize(attributes = {})
        update_attributes(attributes)
      end

      # Retrieves a single group matching the name set in the current instance.
      def get
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, self.class.primary_key, self.name)
          xml.get_key_tag!(base_name, self.class.xml_attribute_names)
        end

        response = request.execute!

        self.class.attributes(:get).each do |name, xml_attribute|
          value = self.class.response_handler.get(response, xml_attribute)

          set_attribute(name, value)
        end

        self
      end

      # Creates a new group and sets all attributes that are settable on create. Other attributes
      # are ignored and would be overwritten by the final +get+ call.
      def create
        request = XmlRequest.prepare do |xml|
          xml.create_tag!(base_name) do |xml|
            self.class.attributes(:create).each do |name, xml_attribute|
              value = self.send(name)

              xml.value_tag!(xml_attribute.name, value) if value.present?
            end
          end
        end

        response = request.execute!

        self.name = self.class.response_handler.get(response, self.class.xml_attribute(:name))

        get
      end

      private

      def update_attributes(attributes) # :nodoc:
        self.class.attribute_names.each do |name|
          value = attributes[name]

          if value.present?
            set_attribute(name, value)
          end
        end
      end

      def set_attribute(name, value) # :nodoc:
        self.send("#{name}=", value)
      end

    end

  end

end
