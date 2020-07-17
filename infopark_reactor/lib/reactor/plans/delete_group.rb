module Reactor
  module Plans
    class DeleteGroup < CommonGroup
      def initialize(*args)
        super()

        (name,), options = separate_arguments(*args)
        @name = name || options[:name]
      end

      def prepare!
        error("name is nil") if @name.nil?
        error("group #{@name} does not exist") unless Reactor::Cm::Group.exists?(@name)
      end

      def migrate!
        group = Reactor::Cm::Group.get(@name)
        group.delete!
      end
    end
  end
end
