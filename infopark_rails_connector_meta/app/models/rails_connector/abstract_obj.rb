module RailsConnector
  # This trick is a workaround to provide compatiblity with both
  # ObjExtensions-enabled versions (older versions) and ObjExtensions-deprecated
  # versions (newest versions) of RailsConnector
  #
  # It first tries to use user-defined Obj class in the newest RailsConnector,
  # which is also an alias for RailsConnector::Obj in the older RailsConnector.
  # If that fails it falls back to ::RailsConnector::BasicObj (new)
  # or ::RailsConnector::Obj (old).
  # The last case shouldn't really ever happen.
  AbstractObj = begin
                  ::Obj
                rescue NameError
                  begin
                    ::RailsConnector::BasicObj
                  rescue NameError
                    ::RailsConnector::Obj
                  end
                end
end
