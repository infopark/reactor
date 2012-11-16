module Reactor
  module Link
    class TemporaryLink
      attr_reader   :url
      attr_accessor :title

      def external? ; raise TypeError, "This link needs to be persisted to gain any meaningful information" ; end
      def internal? ; false ; end

      def initialize(anything)
        link_data = {}
        
        case anything
        when Hash
          link_data = anything
        else
          link_data[:target] = anything
        end

        self.url    = link_data[:target] || link_data[:url] || link_data[:destination_object]
        self.title  = link_data[:title] if link_data.key?(:title)
      end

      def url=(some_target)
        @url = case some_target
        when Obj
          @destination_object = some_target
          some_target.path
        else
          some_target
        end
      end

      def destination_object
        @destination_object ||= Obj.find_by_path(url)
      end

      def id
        nil
      end
    end
  end
end