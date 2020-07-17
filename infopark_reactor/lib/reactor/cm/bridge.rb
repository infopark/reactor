module Reactor
  module Cm
    class Bridge
      # credit goes to Anton
      def self.login_for(sessionId)
        old_username = Reactor::Configuration.xml_access[:username]
        Reactor::Configuration.xml_access[:username] = "root"
        begin
          response = Reactor::Cm::XmlRequest.prepare do |xml|
            xml.tag!("licenseManager-logins")
          end.execute!
          login = nil
          result = response.xpath("//licenseManager-logins/listitem")
          result = [result] unless result.is_a?(Array)
          result.each do |login_data_element|
            properties = deserialize_login_data(login_data_element.text)
            if properties[:sessionId] == sessionId && properties[:interface] == "X"
              login = properties[:login]
              break
            end
          end
          login
        rescue StandardError => e
          Rails.logger.error "Login to CM failed! #{e.class}: #{e.message}"
          nil
        ensure
          Reactor::Configuration.xml_access[:username] = old_username
        end
      end

      def self.deserialize_login_data(serialized_property_list)
        entry_delimiter = /;\r?\n/
        no_braces = serialized_property_list[1..(serialized_property_list.rindex(entry_delimiter) - 1)]
        property_list_lines = no_braces.split(entry_delimiter)
        property_list_lines.each_with_object(properties = {}) do |line, map|
          key, value = line.strip.scan(/^([^=]*) = (.*)$/).first
          if value[0..0] == '"'
            value = value[1..(value.length - 2)]
            value.gsub!(/\\(.)/, '\1')
          end
          map[key.to_sym] = value
        end
        properties
      end
    end
  end
end
