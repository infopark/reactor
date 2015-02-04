# -*- encoding : utf-8 -*-
class CreateAttributeGroupTest < Reactor::Migration
  def self.up
    create_attribute_group :obj_class => 'TestClassWithCustomAttributes', :name => 'my_custom_group' do
      set :title, {'Deutscher Titel' => {:lang => :de}, 'English Title' => {:lang => :en}}
      set :index, 0

      add_attributes ['test_attr_html', 'test_attr_string']
    end

    update_attribute_group :obj_class => 'TestClassWithCustomAttributes', :name => 'my_custom_group' do
      add_attributes    [ 'test_attr_linklist' ]
      remove_attributes [ 'test_attr_html' ]

      set :index, 1
    end
  end

  def self.down
    delete_attribute_group :obj_class => 'TestClassWithCustomAttributes', :name => 'my_custom_group' 
  end
end
