module Reactor
  module Main
    def self.included(base)
      [
        Reactor::Legacy::Base,
        Reactor::Attributes::Base,
        Reactor::Persistence::Base,
        Reactor::Validations::Base,
        Reactor::Permission::Base,
        Reactor::Workflow::Base,
        Reactor::StreamingUpload::Base
      ].each do |mod|
         base.send(:include, mod)
       end
    end
  end
end
