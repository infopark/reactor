# -*- encoding : utf-8 -*-
module RailsConnector
  class BlobMapping < RailsConnector::AbstractModel
    def self.exists?
      self.table_exists?
    end

    def self.get_fingerprint(name)
      find_by_blob_name(name).fingerprint
    end

    def self.get_fingerprint_map(blob_names)
      Hash[self.where(:blob_name => blob_names).select([:blob_name, :fingerprint]).map {|b| [b.blob_name, b.fingerprint] }]
    end
  end
end
