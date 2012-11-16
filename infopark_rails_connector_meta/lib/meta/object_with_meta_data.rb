module RailsConnector

  # This class allows us to read out the version and
  # the reminder information of an Obj
  class ObjectWithMetaData < RailsConnector::InfoparkBase #:nodoc:

    # If we name the class Object, conflicts with the plain Ruby
    # objects inside the RailsConnector will occur.
    def self.table_name
      "#{table_name_prefix}" "objects"
    end

    self.primary_key = :object_id

  end

end
