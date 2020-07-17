require "reactor/workflow/standard"
require "reactor/workflow/empty"
require "reactor/workflow/comment"

module Reactor
  module Workflow
    # This module provides support for Workflow actions and information querying.
    module Base
      # Returns instance of Standard (or Empty..)
      # For the API See Reactor::Workflow::Standard
      def workflow
        @workflow ||=
          if (meta = RailsConnector::ObjectWithMetaData.find_by_object_id(obj_id)).workflow_name.present?
            Standard.new(self, meta)
          else
            Empty.new(self)
          end
      end

      def workflow_comments
        Reactor::Cm::LogEntry.where(objectId: id).map { |entry| Comment.new(entry) }
      end
    end
  end
end
