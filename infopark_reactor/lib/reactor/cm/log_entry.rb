module Reactor
  module Cm
    class LogEntry
      class << self
        def where(conditions = {})
          request = XmlRequest.prepare do |xml|
            where_part(xml, conditions)
            xml.tag!("logEntry-get") do
              xml.tag!("logTime")
              xml.tag!("logText")
              xml.tag!("logType")
              xml.tag!("objectId")
              xml.tag!("receiver")
              xml.tag!("userLogin")
            end
          end
          response = request.execute!

          result = []
          log_entries = response.xpath("//logEntry")
          log_entries = [log_entries] unless log_entries.is_a?(Array)
          log_entries.each do |log_entry_node|
            dict = {}
            log_entry_node.each_element do |value_node|
              dict[value_node.name] = if value_node.name == "logTime"
                                        value_node.elements["isoDateTime"].text.to_s
                                      else
                                        value_node.text.to_s
                                      end
            end

            result << dict
          end

          result
        rescue Reactor::Cm::XmlRequestError => e
          if /#{Regexp.escape('[060001] Es wurde kein Eintrag gefunden.')}/.match?(e.message)
            []
          else
            raise e
          end
        end

        def delete(conditions)
          request = XmlRequest.prepare do |xml|
            where_part(xml, conditions)
            xml.tag!("logEntry-delete")
          end
          response = request.execute!
          response.xpath("//deleteLogEntriesCount").map { |x| x.text.to_s }.first
        end

        protected

        def where_part(xml, conditions)
          xml.tag!("logEntry-where") do
            conditions.each do |key, value|
              xml.tag!(key.to_s, value.to_s)
            end
          end
        end
      end
    end
  end
end
