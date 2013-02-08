# -*- encoding : utf-8 -*-
module Reactor
  module RcIndependent
    module Base
      def really_edited?
        crul_obj.edited?
      end

      def really_released?
        crul_obj.released?
      end
    end
  end
end
