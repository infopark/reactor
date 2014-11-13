module Reactor
  module Cm
    module Permissions
      def self.included(base)
        base.instance_eval do
          attribute :global_permissions, :name => :globalPermissions, :type => :list
        end
      end

      # Returns true, if a global permission with the given +name+ exists, false otherwise.
      def global_permission?(name)
        self.global_permissions.include?(name.to_s)
      end

      # Add the given +permissions+ to the current set of group permissions.
      def grant_global_permissions!(permissions)
        permissions = permissions.kind_of?(Array) ? permissions : [permissions]
        permissions = self.global_permissions | permissions

        set_global_permissions!(permissions)
      end

      # Take away the given +permissions+ from the current set of group permissions.
      def revoke_global_permissions!(permissions)
        permissions = permissions.kind_of?(Array) ? permissions : [permissions]
        permissions = self.global_permissions - permissions

        set_global_permissions(permissions)
      end

      # Set the group permissions to the given +permissions+.
      def set_global_permissions!(permissions)
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, self.class.primary_key, self.name)
          xml.set_key_tag!(base_name, self.class.xml_attribute(:global_permissions).name, permissions)
        end

        request.execute!

        self.global_permissions = permissions
      end
    end
  end
end
