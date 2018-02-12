# -*- encoding : utf-8 -*-
def with(object)
  puts "SEED with #{object.inspect}"
  yield(object) if block_given? && !object.nil?
end

def without(dont_run_block)
  yield if block_given? && !dont_run_block
end

# %x( docker exec -it fiona7_reactor /fiona/CMS-Fiona-7.0.1/instance/default/bin/CM -restore /fiona/empty_cms )
# %x( docker exec -it fiona7_reactor /fiona/CMS-Fiona-7.0.1/instance/default/bin/CM -unrailsify )
# %x( docker exec -it fiona7_reactor /fiona/CMS-Fiona-7.0.1/instance/default/bin/CM -railsify )

klass_name = "TestClassWithCustomAttributes"
klass = Reactor::Cm::ObjClass.create(klass_name, 'publication') rescue nil
klass = Reactor::Cm::ObjClass.get(klass_name)

attributes = []
%w{linklist date html string text}.each do |attr_type|
  attr = "test_attr_#{attr_type}"
  Reactor::Cm::Attribute.create(attr, attr_type) rescue  nil
  attributes << attr
end

%w{enum multienum}.each do |enum_attr_type|
  attr = "test_attr_#{enum_attr_type}"
  cm_attr = Reactor::Cm::Attribute.create(attr, enum_attr_type) rescue  nil
  if cm_attr
    cm_attr.set(:values, ['value1', 'value2', 'value3'])
    cm_attr.save!
  end
  attributes << attr
end

klass.attributes = attributes
klass.save!

with(Obj.find_by_path('/test_obj_with_custom_attributes'), &:destroy)

Obj.create(:name => 'test_obj_with_custom_attributes', :parent => '/', :obj_class => klass_name)

without(Obj.find_by_path('/object_sure_to_exist')) do
  Obj.create(:name => 'object_sure_to_exist', :parent => '/', :obj_class => klass_name)
end

RELEASABLE_CLASS = 'ReleasableClass'

without(Reactor::Cm::ObjClass.exists?(RELEASABLE_CLASS)) do
  Reactor::Cm::ObjClass.create(RELEASABLE_CLASS, 'publication')
end

OTHER_OBJ_CLASS = 'OtherObjClass'

without(Reactor::Cm::ObjClass.exists?(OTHER_OBJ_CLASS)) do
  Reactor::Cm::ObjClass.create(OTHER_OBJ_CLASS, 'publication')
end

with(Obj.find_by_path('/valid_object_for_release'), &:destroy)

Obj.create(:name => 'valid_object_for_release', :parent => '/', :obj_class => RELEASABLE_CLASS)

without(Obj.find_by_path('/valid_object_for_edit')) do
  Obj.create(:name => 'valid_object_for_edit', :parent => '/', :obj_class => RELEASABLE_CLASS)
end

with(Obj.find_by_path('/valid_object_for_edit')) do |o|
  o.release! if o.edited?
end


UNRELEASABLE_CLASS = 'UnreleasableClass'

without(Reactor::Cm::ObjClass.exists?(UNRELEASABLE_CLASS)) do
  with Reactor::Cm::ObjClass.create(UNRELEASABLE_CLASS, 'publication') do |k|
    k.mandatory_attributes = [:title]
  end
end

without(Obj.find_by_path('/invalid_object_for_release')) do
  Obj.create(:name => 'invalid_object_for_release', :parent => '/', :obj_class => UNRELEASABLE_CLASS)
end

PLAIN_CLASS = 'PlainObjClass'
without(Reactor::Cm::ObjClass.exists?(PLAIN_CLASS)) do
  Reactor::Cm::ObjClass.create(PLAIN_CLASS, 'publication')
end

Obj.create(:name => 'object_without_resolved_refs', :parent => '/', :obj_class => PLAIN_CLASS) rescue nil
o = Obj.find_by_path('/object_without_resolved_refs')
o.send(:prevent_resolve_refs)
o.set(:body, '<a href="/object_sure_to_exist">link</a>')
o.save

Obj.create(:name => 'object_without_resolved_refs2', :parent => '/', :obj_class =>PLAIN_CLASS, :body => '<a href="/object_sure_to_exist">link</a>') rescue nil
o = Obj.find_by_path('/object_without_resolved_refs2')
o.send(:prevent_resolve_refs)
o.set(:body, '<a href="/object_sure_to_exist">link</a>')
o.save

without(Obj.find_by_path('/linktestbead')) do
  Obj.create(:name => 'linktestbead', :parent => '/', :obj_class => PLAIN_CLASS)
end

with(Obj.find_by_path('/linktestbead')) do |parent|
  parent.children.each(&:destroy)
end

LINKTEST_CLASS = 'LinktestClass'
without(Reactor::Cm::ObjClass.exists?(LINKTEST_CLASS)) do
  Reactor::Cm::ObjClass.create(LINKTEST_CLASS, 'publication')
end
Reactor::Cm::ObjClass.get(LINKTEST_CLASS).attributes = ['test_attr_text']

VALIDATION_LINK_ATTR = 'between_two_and_four_links'
without(Reactor::Cm::Attribute.exists?(VALIDATION_LINK_ATTR)) do
  Reactor::Cm::Attribute.create(VALIDATION_LINK_ATTR, 'linklist')
end

GENERIC_CLASS = 'Resource'
without(Reactor::Cm::ObjClass.exists?(GENERIC_CLASS)) do
  Reactor::Cm::ObjClass.create(GENERIC_CLASS, 'generic')
end

link = Reactor::Cm::Attribute.get(VALIDATION_LINK_ATTR)
link.set('minSize', 2)
link.set('maxSize', 4)
link.save!

VALIDATION_CLASS = 'ValidationClass'
without(Reactor::Cm::ObjClass.exists?(VALIDATION_CLASS)) do
  Reactor::Cm::ObjClass.create(VALIDATION_CLASS, 'publication')
end
Reactor::Cm::ObjClass.get(VALIDATION_CLASS).attributes = [VALIDATION_LINK_ATTR]


klass = Reactor::Cm::ObjClass.create('image', 'image') rescue nil
Obj.upload(File.open(Rails.root + 'spec/fixtures/53b01fb15ffe3a9e83675a3c80d639c6.jpg', 'r'), 'jpg', parent: '/', name: 'image_sure_to_exist', obj_class: 'image').release!
Obj.upload(File.open(Rails.root + 'spec/fixtures/53b01fb15ffe3a9e83675a3c80d639c6.jpg', 'r'), 'jpg', parent: '/', name: 'image_sure_to_exist2', obj_class: 'image').release!

unless Reactor::Cm::User::Internal.exists?('spresley')
  user = Reactor::Cm::User::Internal.create('spresley', 'not_root_group')
  user.email = 'spresley@infopark'
  user.real_name = 'Spresley Presley'
  user.save!
end
