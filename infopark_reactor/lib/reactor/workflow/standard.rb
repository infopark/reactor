module Reactor
  module Workflow
    class Standard
      WORKFLOW_ACTIONS = %i(take forward reject commit release sign).freeze

      def initialize(obj, meta_obj)
        @obj = obj
        @meta_obj = meta_obj
      end

      def empty?
        false
      end

      def name
        @meta_obj.workflow_name
      end

      WORKFLOW_ACTIONS.each do |action|
        define_method :"#{action}?" do
          valid_action?(action)
        end

        define_method :"#{action}!" do |*args|
          @obj.send(:crul_obj).send(:"#{action}!", *args)
        end
      end

      protected

      def valid_action?(action)
        @obj.send(:crul_obj).valid_actions.include?(action.to_s)
      end
    end
  end
end
