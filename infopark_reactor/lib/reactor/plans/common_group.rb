# -*- encoding : utf-8 -*-
module Reactor

  module Plans

    class CommonGroup

      include Prepared

      ALLOWED_PARAMS = [
        :users, 
        :global_permissions, 
        :real_name, 
        :owner,
      ]

      def initialize
        @params = {}
      end

      def set(key, value)
        @params[key.to_sym] = value
      end

      def migrate!
        raise "#{self.class.name} did not implement migrate!"
      end

      protected

      def prepare_params!(group = nil)
        @params.keys.each { |key| error("unknown parameter: #{key}") unless ALLOWED_PARAMS.include?(key) }
      end

      def migrate_params!(group)
        @params.each { |key, value| group.send("#{key}=", value) }

        group.save!
      end

    end

  end

end
