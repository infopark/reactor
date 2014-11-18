require 'reactor/rails_connector_meta'
require 'reactor/legacy'
require 'reactor/attributes'
require 'reactor/persistence'
require 'reactor/validations'
require 'reactor/permission'
require 'reactor/workflow'
require 'reactor/streaming_upload'

module Reactor
  module Main
    def self.included(base)
      [RailsConnector::Meta, Reactor::Legacy::Base,
       Reactor::Attributes::Base, Reactor::Persistence::Base,
       Reactor::Validations::Base, Reactor::Permission::Base,
       Reactor::Workflow::Base, Reactor::StreamingUpload::Base].each do |mod|
         base.send(:include, mod)
       end
    end
  end
end
