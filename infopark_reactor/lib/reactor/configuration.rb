module Reactor
  class Configuration
    class << self
      attr_accessor :xml_access, :sanitize_obj_name
    end

    self.sanitize_obj_name = true
  end
end
