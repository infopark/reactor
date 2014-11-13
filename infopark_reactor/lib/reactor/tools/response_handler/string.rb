# -*- encoding : utf-8 -*-
require 'reactor/tools/response_handler/base'

module Reactor

  module ResponseHandler
    
    class String < Base
      
      def get(response, string)
        super(response, string)

        self.response.xpath(string)
      end

    end
    
  end

end
