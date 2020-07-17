require "reactor/cm/job"
require "reactor/plans/common_job"

module Reactor
  module Plans
    class DeleteJob < CommonJob
      def initialize(*args)
        super()
        (name, x), options = separate_arguments(*args)
        @name = name || options[:name]
      end

      def prepare!
        error("name is nil") if @name.nil?
        error("job #{@name} does not exist") unless Reactor::Cm::Job.exists?(@name)
      end

      def migrate!
        Reactor::Cm::Job.delete!(@name)
      end
    end
  end
end
