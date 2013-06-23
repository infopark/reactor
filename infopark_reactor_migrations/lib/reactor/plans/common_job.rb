# -*- encoding : utf-8 -*-
module Reactor
  module Plans
    class CommonJob
      include Prepared

      ALLOWED_PARAMS = [:title, :is_active, :comment, :exec_login, :exec_perm, :schedule, :script]

      def initialize
        @params = {}
      end

      def set(key,value)
        @params[key.to_sym] = value
      end

      def migrate!
        raise "#{self.class.name} did not implement migrate!"
      end

      protected
      def prepare_params!(job=nil)
        @params.keys.each{|k| error("unknown parameter: #{k}") unless ALLOWED_PARAMS.include? k}
      end

      def migrate_params!(job)
        @params.each{|k,v|job.send(:"#{k}=",v)}
        job.save!
      end
    end
  end
end
