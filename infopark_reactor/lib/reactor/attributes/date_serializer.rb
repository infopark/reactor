# -*- encoding : utf-8 -*-
module Reactor
  module Attributes
    class DateSerializer
      def initialize(attr, value)
        @attr, @value = attr, value
      end

      def serialize
        @serialized ||= serialize_date
      end

      private
      def serialize_date
        if @value.is_a?(Time)
          @value.dup.utc.to_iso
        elsif @value.is_a?(String)
          if iso_format?(@value)
            @value
          elsif !@value.empty?
            Time.zone.parse(@value).utc.to_iso
          else
            # empty string <=> clear date
            nil
          end
        else
          @value
        end
      end

      def iso_format?(val)
        val =~ /^[0-9]{14}$/
      end
    end
  end
end
