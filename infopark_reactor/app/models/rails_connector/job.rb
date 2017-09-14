# -*- encoding : utf-8 -*-
module RailsConnector

  # This class allows us to read out basic information about jobs
  class Job < RailsConnector::AbstractModel

    self.primary_key = "job_id"

    def self.table_name
      "#{table_name_prefix}" "jobs"
    end
  end

end
