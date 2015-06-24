module RailsConnector
  class ObjClassAttr < RailsConnector::AbstractModel
    has_many :custom_attributes_raw, :class_name => '::RailsConnector::Attribute', :foreign_key => 'attribute_id', :primary_key => 'attribute_id'
  end
end
