module Reactor
  module Workflow
    class Comment < Struct.new(:time, :text, :type, :obj_id, :receiver, :user)
      def initialize(log_entry)
        super(
          parse_time(log_entry["logTime"]),
          log_entry["logText"],
          log_entry["logType"],
          log_entry["objectId"],
          log_entry["receiver"],
          log_entry["userLogin"]
        )
      end

      def object
        ::AbstractObj.find(obj_id)
      end

      alias_method :obj, :object

      protected

      def parse_time(time)
        Time.from_iso(time)
      end
    end
  end
end
