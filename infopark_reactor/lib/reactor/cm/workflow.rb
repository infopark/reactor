# -*- encoding : utf-8 -*-
require 'reactor/cm/object_base'

module Reactor
  module Cm
    class Workflow < ObjectBase
      # Attribute definitions
      attribute :name, :except => [:set]
      attribute :title
      attribute :is_enabled, :name => :isEnabled
      attribute :edit_groups, :name => :editGroups, :type => :list
      attribute :mutiple_signatures, :name => :allowsMultipleSignatures
      # This attribute should be used as follows:
      # workflow.signatures = [{:attribute => 'mySigAttr', :group => 'myGroup'},{:attribute => 'mySigAttr', :group => 'myOtherGroup'}]
      attribute :signatures, :name => :signatureDefs, :type => :signaturelist

      primary_key :name

      # Creates a workflow with given name. A list of edit groups
      # may also be specified - otherwise it defaults to empty list
      def self.create(name, edit_groups = [])
        super(name, {:name => name, :editGroups => edit_groups})
      end

      def self.serialize_attribute_to_xml(xml, xml_attribute, value)
        if xml_attribute.name.to_sym == :signatureDefs
          xml.tag!('signatureDefs') do
            (value || []).each do |hash|
              xml.tag!('listitem') do
                xml.tag!('listitem', hash[:attribute])
                xml.tag!('listitem', hash[:group])
              end
            end
          end
        else
          super(xml, xml_attribute, value)
        end
      end
    end
  end
end
