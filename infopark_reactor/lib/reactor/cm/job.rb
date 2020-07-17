require "reactor/cm/object_base"

module Reactor
  module Cm
    class Job < ObjectBase
      attribute :name, except: [:set]
      attribute :title
      attribute :is_active, name: :isActive
      attribute :comment
      attribute :exec_login, name: :execLogin
      attribute :exec_perm, name: :execPerm
      # This attribute has the following format:
      # [{:years => ['2001', '2002']}, {:years => ['2002', '2003'], :minutes => ['11', '12']}]
      attribute :schedule, type: :schedule
      attribute :script

      primary_key :name

      def self.serialize_attribute_to_xml(xml, xml_attribute, value)
        if xml_attribute.type.to_sym == :schedule
          xml.tag!("schedule") do
            (value || []).each do |schedule_entry|
              xml.tag!("listitem") do
                schedule_entry.each do |dim, values|
                  xml.tag!("dictitem") do
                    xml.tag!("key") do
                      xml.text!(dim.to_s)
                    end
                    xml.tag!("value") do
                      values.each do |val|
                        xml.tag!("listitem", val)
                      end
                    end
                  end
                end
              end
            end
          end
        else
          super(xml, xml_attribute, value)
        end
      end

      def self.create(pk_value, attributes = {})
        request = XmlRequest.prepare do |xml|
          xml.create_tag!(base_name) do
            attributes.merge(name: pk_value).each do |attr_name, attr_value|
              serialize_attribute_to_xml(xml, xml_attribute(attr_name), attr_value)
            end
          end
        end

        request.execute!

        get(pk_value)
      end

      def exec
        simple_commnad("exec")
      end

      def cancel
        simple_command("cancel")
      end

      protected

      def simple_command(cmd_name)
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, "name", name)
          xml.tag!("#{base_name}-#{cmd_name}")
        end
        request.execute!
      end
    end
  end
end
