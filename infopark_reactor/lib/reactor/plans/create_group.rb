require "reactor/plans/common_group"

module Reactor
  module Plans
    class CreateGroup < CommonGroup
      def initialize(*args)
        super()

        (name,), options = separate_arguments(*args)

        @name = name || options[:name]

        set(:name, @name)
     end

      def prepare!
        error("name is nil") if @name.nil?
        error("group #{@name} already exists") if Reactor::Cm::Group.exists?(@name)

        prepare_params!(nil)
      end

      def migrate!
        Reactor::Cm::Group.create(@params)
      end
    end
  end
end
