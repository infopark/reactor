# -*- encoding : utf-8 -*-
require 'reactor/cm/job'
require 'reactor/plans/common_job'

module Reactor
  module Plans
    class UpdateJob < CommonJob
      def initialize(*args)
        super()

        (name, _), options = separate_arguments(*args)
        @name = name || options[:name]
      end

      def prepapre!
        error('name is nil') if @name.nil?
        error("job #{@name} not found") unless Reactor::Cm::Job.exists?(@name)

        prepare_params!(nil)
      end

      def migrate!
        job = Reactor::Cm::Job.get(@name)
        migrate_params!(job)
      end

    end

  end

end
