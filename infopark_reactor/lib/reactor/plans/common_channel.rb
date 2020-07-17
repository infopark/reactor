module Reactor
  module Plans
    class CommonChannel
      include Prepared

      ALLOWED_PARAMS = [:title].freeze

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

      def prepare_params!(_channel = nil)
        @params.keys.each { |k| error("unknown parameter: #{k}") unless ALLOWED_PARAMS.include? k }
      end

      def migrate_params!(channel)
        @params.each { |k, v| channel.send(:"#{k}=", v) }
        channel.save!
      end
    end
  end
end
