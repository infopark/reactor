require "reactor/plans/prepared"

module Reactor
  module Plans
    class DeleteObj
      include Prepared

      def initialize(opts = {})
        @key = opts[:obj_id] || opts[:path]
      end

      def prepare!
        error("object (key=#{@key}) not found") unless Reactor::Cm::Obj.exists?(@key)
      end

      def migrate!
        obj = Reactor::Cm::Obj.get(@key)
        obj.delete!
      end
    end
  end
end
