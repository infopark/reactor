module Reactor
  module Cm
    class LogEntry
      class << self
        def where(conditions = {})
          request = XmlRequest.prepare do |xml|
            where_part(xml, conditions)
            xml.tag!('logEntry-get') do
              xml.tag!('logTime')
              xml.tag!('logText')
              xml.tag!('logType')
              xml.tag!('objectId')
              xml.tag!('receiver')
              xml.tag!('userLogin')
            end
          end
          response = request.execute!
          
          result = []
          response.xpath('//logEntry').each do |log_entry_node|
            dict = {}
            log_entry_node.each_element do |value_node|
              if value_node.name == 'logTime'
                dict[value_node.name] = value_node.elements['isoDateTime'].text.to_s
              else
                dict[value_node.name] = value_node.text.to_s
              end
            end

            result << dict
          end

          return result
        rescue Reactor::Cm::XmlRequestError => e
          if e.message =~ /#{Regexp.escape('[060001] Es wurde kein Eintrag gefunden.')}/
            return []
          else
            raise e
          end
        end

        def delete(conditions)
          request = XmlRequest.prepare do |xml|
            where_part(xml, conditions)
            xml.tag!('logEntry-delete')
          end
          response = request.execute!
          result = response.xpath('//deleteLogEntriesCount').map {|x| x.text.to_s }.first
        end

        protected
        def where_part(xml, conditions)
          xml.tag!('logEntry-where') do
            conditions.each do |key, value|
              xml.tag!(key.to_s, value.to_s)
            end
          end
        end
      end
    end
  end
end
