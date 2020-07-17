module Reactor
  module WhereQuery
    def where(key, value)
      request = Cm::XmlRequest.prepare do |xml|
        xml.where_tag!(base_name) do
          xml.tag!(key) do
            xml.text!(value) if value
          end
        end

        xml.get_tag!(base_name) do
          attributes.each do |_, xml_attribute|
            xml.tag!(xml_attribute.name)
          end
        end
      end

      response = request.execute!
      result = response.xpath("//#{base_name}")
      result = [result] unless result.is_a?(Array)
      result.map do |elem|
        values = response_handler.multiple(elem, attributes.values)
        instance = new
        values.each do |name, response_value|
          pair = attributes.find { |_n, a| a.name.to_sym == name.to_sym }
          attribute = pair[0]
          instance.send(:"#{attribute}=", response_value)
        end
        instance
      end
    rescue Cm::XmlRequestError
      []
    end
  end
end
