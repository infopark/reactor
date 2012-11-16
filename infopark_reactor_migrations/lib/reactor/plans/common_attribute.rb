module Reactor
  module Plans
    class CommonAttribute
      include Prepared

      ALLOWED_PARAMS = [:callback, :helpText, :maxSize, :minSize,
        :title, :values]

      def initialize
        @params = {}
      end

      def set(key,value)
        @params[key.to_sym] = value
      end

      def migrate!
        raise "#{self.class.name} did not implement migrate!"
      end

      protected
      def prepare_params!(attribute=nil)
        @params.keys.each{|k| error("unknown parameter: #{k}") unless ALLOWED_PARAMS.include? k}
      end

      def migrate_params!(attribute)
        @params.each{|k,v|attribute.set(k,v)}
        attribute.save!
      end
    end
  end
end