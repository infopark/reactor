module Reactor
  module Plans
    class RenameObjClass
      include Prepared

      def initialize(*args)
        (from, to), options = separate_arguments(*args)
        @from = from || options[:from]
        @to = to || options[:to]
      end

      def prepare!
        error("from is nil") if @from.nil?
        error("to is nil") if @to.nil?
        error("from does not exist") unless Reactor::Cm::ObjClass.exists?(@from)
        error("to does exist") if Reactor::Cm::ObjClass.exists?(@to)
      end

      def migrate!
        Reactor::Cm::ObjClass.rename(@from, @to)
      end
    end
  end
end
