require "reactor/cm/channel"
require "reactor/plans/common_channel"

module Reactor
  module Plans
    class CreateChannel < CommonChannel
      def initialize(*args)
        super()
        (name, x), options = separate_arguments(*args)
        @name = name || options[:name]
      end

      def prepare!
        error("name is nil") if @name.nil?
      end

      def migrate!
        channel = Reactor::Cm::Channel.create(@name)
        migrate_params!(channel)
      end
    end
  end
end
