module RailsConnector
  class BlobMapping < RailsConnector::InfoparkBase
    def self.exists?
      self.table_exists?
    end

    def self.get_fingerprint(name)
      find_by_blob_name(name).fingerprint
    end
  end
end