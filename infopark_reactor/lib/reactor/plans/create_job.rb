require "reactor/cm/job"
require "reactor/plans/common_job"

module Reactor
  module Plans
    class CreateJob < CommonJob
      def initialize(*args)
        super()
        (name, x), options = separate_arguments(*args)
        @name = name || options[:name]
      end

      def prepare!
        error("name is nil") if @name.nil?
      end

      def migrate!
        Reactor::Cm::Job.create(@name, @params)
      end
    end
  end
end
