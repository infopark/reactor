# -*- encoding : utf-8 -*-
module Reactor
  module Plans
    class UpdateObj
      include Prepared

      def initialize(opts={})
        @key = opts[:obj_id] || opts[:path]
        @attrs = {}
      end

      def set(key, value)
        @attrs[key.to_sym] = value
      end

      def prepare!
        error("object (key=#{@key}) not found") if not Reactor::Cm::Obj.exists?(@key)
        #TODO: attribute check
      end

      def migrate!
        obj = Reactor::Cm::Obj.get(@key)
        @attrs.each do |key,value|
          @obj.set(key,value)
        end
        @obj.save!
        @obj.release!
      end
    end
  end
end
