module Reactor
  module Workflow
    class Empty < Standard
      def initialize(obj)
        @obj = obj
      end

      def empty?
        true
      end

      def name
        nil
      end

      WORKFLOW_ACTIONS.each do |action|
        define_method :"#{action}?" do
          false
        end

        define_method :"#{action}!" do
          nil
        end
      end
    end
  end
end