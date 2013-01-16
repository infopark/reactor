module Reactor
  module Plans
    class DeleteChannel < CommonAttribute
      def initialize(*args)
        super()
        (name, x), options = separate_arguments(*args)
        @name = name || options[:name]
      end

      def prepare!
        error("name is nil") if @name.nil?
        error("channel #{@name} does not exist") if not Reactor::Cm::Channel.exists?(@name)
      end

      def migrate!
        Reactor::Cm::Channel.get(@name).delete!
      end

    end
  end
end
