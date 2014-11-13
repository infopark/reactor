module RailsConnector
  AbstractModel = begin
                  ::RailsConnector::InfoparkBase
                rescue NameError
                  ::RailsConnector::CmsBaseModel
                end
end
