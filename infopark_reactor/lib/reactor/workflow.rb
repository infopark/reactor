# -*- encoding : utf-8 -*-
require 'reactor/workflow/standard'
require 'reactor/workflow/empty'

module Reactor
  module Workflow
    # This module provides support for Workflow actions and information querying.
    module Base
      # Returns instance of Standard (or Empty..)
      # For the API See Reactor::Workflow::Standard
      def workflow
        @workflow ||= if ((meta=RailsConnector::ObjectWithMetaData.find_by_object_id(self.obj_id)).workflow_name.present?)
          Standard.new(self,meta)
        else
          Empty.new(self)
        end
      end

      def workflow_comments
        Reactor::Cm::LogEntry.where(:objectId => self.id).map {|entry| Comment.new(entry) }
      end
    end

    class Comment < Struct.new(:time, :text, :type, :object_id, :receiver, :user)
      def initialize(log_entry)
        super(
          parse_time(log_entry['logTime']),
          log_entry['logText'],
          log_entry['logType'],
          log_entry['objectId'],
          log_entry['receiver'],
          log_entry['userLogin']
        )
      end

      def object
        ::AbstractObj.find(self.object_id)
      end

      alias obj object

      protected
      def parse_time(time)
        Time.from_iso(time)
      end
    end
  end
end
