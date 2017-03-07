module Reactor
  module WhereQuery
    def where(key, value)
      request = Cm::XmlRequest.prepare do |xml|
        xml.where_tag!(self.base_name) do
          xml.tag!(key) do
            if value
              xml.text!(value)
            end
          end
        end

        xml.get_tag!(self.base_name) do
          self.attributes.each do |_, xml_attribute|
            xml.tag!(xml_attribute.name)
          end
        end
      end

      response = request.execute!
      result = response.xpath("//#{self.base_name}")
      result = [result] unless result.kind_of?(Array)
      result.map do |elem|
        values = {}
        values = self.response_handler.multiple(elem, self.attributes.values)
        instance  = self.new
        values.each do |name, value|
          instance.instance_variable_set(:"@#{name}", value)
        end
        instance
      end
    rescue Cm::XmlRequestError
      []
    end
  end
end
