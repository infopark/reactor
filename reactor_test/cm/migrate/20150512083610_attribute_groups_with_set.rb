# -*- encoding : utf-8 -*-
class AttributeGroupsWithSet < Reactor::Migration
  def self.up
    create_attribute_group :obj_class => 'TestClassWithCustomAttributes', :name => 'another_group' do
      set :title, "just title"
      set :attributes, ['test_attr_text']
    end
  end

  def self.down
    delete_attribute_group :obj_class => 'TestClassWithCustomAttributes', :name => 'another_group'
  end
end
