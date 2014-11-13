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
  root_class = begin
                 ::RailsConnector::BasicObj
               rescue NameError
                 ::RailsConnector::Obj
               end
  AbstractObj = begin
                  if ::Obj < root_class
                    ::Obj
                  else
                    root_class
                  end
                rescue NameError
                  root_class
                end

  class AbstractObj
    def self.compute_type(type_name)
      try_type { type_name.constantize } || self 
    end
  end
end
