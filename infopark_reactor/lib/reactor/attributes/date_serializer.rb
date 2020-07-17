# return always utc-timestam in iso format 'YYYYMMDDhhmmss'
module Reactor
  module Attributes
    class DateSerializer
      def initialize(key, value)
        @attr = key
        @value = value
      end

      def serialize
        @serialized ||= serialize_date(@value)
      end

      private

      def serialize_date(value)
        return nil if value.blank?

        value = value.to_datetime if value.is_a?(Date)
        if value.is_a?(Time) || value.is_a?(DateTime)
          value.utc.to_s(:number)
        elsif value.is_a?(String)
          if iso_format?(value)
            value
          else
            begin
              DateTime.parse(value).utc.to_s(:number)
            rescue ArgumentError
              nil
            end
          end
        end
      end

      def iso_format?(val)
        val =~ /^[0-9]{14}$/
      end
    end
  end
end
