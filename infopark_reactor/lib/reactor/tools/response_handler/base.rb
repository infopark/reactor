# -*- encoding : utf-8 -*-
module Reactor

  module ResponseHandler
    
    # Common base class to handle a xml response. Provides helper methods to extract the content 
    # from a xml response.
    class Base

      attr_accessor :response
      attr_accessor :context

      # Common strategy method for each sub class.
      def get(response, context)
        @response = response
        @context = context
      end
      
    end

  end

end
