# -*- encoding : utf-8 -*-
require 'meta'

module ObjExtensions

  # Infopark Rails Connector enables the developer to define specific behavior
  # for Fiona CMS classes by using Single Table Inheritance
  # (http://www.martinfowler.com/eaaCatalog/singleTableInheritance.html).
  #
  # If you wish to decorate the model Obj with extra behavior, you will need to
  # add it here.
  #
  # In addition, you will need to edit your environment(s) accordingly:
  #
  #     def init_rails_connector
  #       ObjExtensions.enable
  #       ...
  #     end

  def self.enable
    Obj.class_eval do
      include RailsConnector::Meta

      include Reactor::Legacy::Base
      include Reactor::Attributes::Base
      include Reactor::Persistence::Base
      include Reactor::Validations::Base
      include Reactor::Permission::Base

      include Reactor::Workflow::Base
      include Reactor::StreamingUpload::Base

    end
  end
end
