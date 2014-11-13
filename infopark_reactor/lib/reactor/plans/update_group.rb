# -*- encoding : utf-8 -*-
module Reactor

  module Plans

    class UpdateGroup < CommonGroup

      def initialize(*args)
        super()

        (name, _), options = separate_arguments(*args)
        @name = name || options[:name]
      end

      def prepapre!
        error('name is nil') if @name.nil?
        error("group #{@name} not found") unless Reactor::Cm::Group.exists?(@name)

        prepare_params!(nil)
      end

      def migrate!
        group = Reactor::Cm::Group.get(@name)
        migrate_params!(group)
      end

    end

  end

end
