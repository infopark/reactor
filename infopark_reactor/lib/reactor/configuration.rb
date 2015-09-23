# -*- encoding : utf-8 -*-
module Reactor
  class Configuration
    class << self
      attr_accessor :xml_access
      attr_accessor :sanitize_obj_name
    end

    self.sanitize_obj_name = true
  end
end
