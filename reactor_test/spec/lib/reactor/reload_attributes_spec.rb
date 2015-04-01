require 'spec_helper'

describe "Attribute reloading" do
  cleanup = proc do
    Obj.where("path LIKE '/reloaded_test%'").each do |obj|
      obj.destroy
    end
    Reactor::Cm::ObjClass.get('ReloadedClass').delete! if RailsConnector::ObjClass.exists?(:obj_class_name => 'ReloadedClass')
    Reactor::Cm::Attribute.get('reloaded_attribute').delete! if RailsConnector::Attribute.exists?(:attribute_name => 'reloaded_attribute')
    Reactor::Cm::Attribute.get('reloaded_attribute2').delete! if RailsConnector::Attribute.exists?(:attribute_name => 'reloaded_attribute2')
    Object.send(:remove_const, :ReloadedClass) if Object.const_defined?(:ReloadedClass)
  end

  before &cleanup
  after  &cleanup

  before do
    Reactor::Cm::Attribute.create('reloaded_attribute', 'string')
    Reactor::Cm::Attribute.create('reloaded_attribute2', 'linklist')
    @klass = Reactor::Cm::ObjClass.create('ReloadedClass', 'publication')

    class ::ReloadedClass < ::Obj
    end
  end

  specify do
    # No attribute -> method missing
    empty = ::ReloadedClass.new
    expect { empty.reloaded_attribute }.to raise_error(NoMethodError)
    expect { empty.reloaded_attribute='test'}.to raise_error(NoMethodError)

    created = ::ReloadedClass.create(name: 'reloaded_test', parent: '/')
    expect { created.reloaded_attribute }.to raise_error(NoMethodError)
    expect { created.reloaded_attribute='test'}.to raise_error(NoMethodError)

    loaded = ReloadedClass.find(created.id)
    expect { loaded.reloaded_attribute }.to raise_error(NoMethodError)
    expect { loaded.reloaded_attribute='test' }.to raise_error(NoMethodError)

    # First add attribute
    @klass.attributes = ['reloaded_attribute']

    # attr_defs does the work for instances loaded from DB
    expect { empty.reloaded_attribute }.to raise_error(NoMethodError)
    expect { empty.reloaded_attribute='test'}.to raise_error(NoMethodError)

    expect { created.reloaded_attribute }.to raise_error(NoMethodError)
    expect { created.reloaded_attribute='test'}.to raise_error(NoMethodError)

    expect { loaded.reloaded_attribute }.to raise_error(NoMethodError)
    expect { loaded.reloaded_attribute='test' }.to raise_error(NoMethodError)

    empty2 = ::ReloadedClass.new
    expect { empty2.reloaded_attribute }.to raise_error(NoMethodError)
    expect { empty2.reloaded_attribute='test'}.to raise_error(NoMethodError)

    loaded2 = ReloadedClass.find(created.id)
    expect { loaded2.reloaded_attribute }.not_to raise_error
    expect { loaded2.reloaded_attribute='test' }.to raise_error(NoMethodError)

    # Reload attributes only for created
    created.reload_attributes

    # created does not raise an error, others do
    expect { empty.reloaded_attribute }.to raise_error(NoMethodError)
    expect { empty.reloaded_attribute='test'}.to raise_error(NoMethodError)

    expect { created.reloaded_attribute }.not_to raise_error()
    expect { created.reloaded_attribute='test'}.not_to raise_error()

    expect { loaded.reloaded_attribute }.to raise_error(NoMethodError)
    expect { loaded.reloaded_attribute='test' }.to raise_error(NoMethodError)

    empty2 = ::ReloadedClass.new
    expect { empty2.reloaded_attribute }.to raise_error(NoMethodError)
    expect { empty2.reloaded_attribute='test'}.to raise_error(NoMethodError)

    loaded2 = ReloadedClass.find(created.id)
    expect { loaded2.reloaded_attribute }.not_to raise_error
    expect { loaded2.reloaded_attribute='test' }.to raise_error(NoMethodError)

    # reload attributes on the singleton class of empty
    empty.singleton_class.reload_attributes('ReloadedClass')

    # now empty and create do not raise an errors, others do
    expect { empty.reloaded_attribute }.not_to raise_error()
    expect { empty.reloaded_attribute='test'}.not_to raise_error()

    expect { created.reloaded_attribute }.not_to raise_error()
    expect { created.reloaded_attribute='test'}.not_to raise_error()

    expect { loaded.reloaded_attribute }.to raise_error(NoMethodError)
    expect { loaded.reloaded_attribute='test' }.to raise_error(NoMethodError)

    empty2 = ::ReloadedClass.new
    expect { empty2.reloaded_attribute }.to raise_error(NoMethodError)
    expect { empty2.reloaded_attribute='test'}.to raise_error(NoMethodError)

    loaded2 = ReloadedClass.find(created.id)
    expect { loaded2.reloaded_attribute }.not_to raise_error
    expect { loaded2.reloaded_attribute='test' }.to raise_error(NoMethodError)

    # reload on class
    ReloadedClass.reload_attributes

    # no more errors
    expect { empty.reloaded_attribute }.not_to raise_error()
    expect { empty.reloaded_attribute='test'}.not_to raise_error()

    expect { created.reloaded_attribute }.not_to raise_error()
    expect { created.reloaded_attribute='test'}.not_to raise_error()

    expect { loaded.reloaded_attribute }.not_to raise_error
    expect { loaded.reloaded_attribute='test' }.not_to raise_error

    empty2 = ::ReloadedClass.new
    expect { empty2.reloaded_attribute }.not_to raise_error
    expect { empty2.reloaded_attribute='test'}.not_to raise_error

    loaded2 = ReloadedClass.find(created.id)
    expect { loaded2.reloaded_attribute }.not_to raise_error
    expect { loaded2.reloaded_attribute='test' }.not_to raise_error

  end

  specify do
    created = ::ReloadedClass.create(name: 'reloaded_test', parent: '/')

    # First add attribute
    @klass.attributes = ['reloaded_attribute2']

    created.reload_attributes

    created.reloaded_attribute2 = ['http://google.com']

    created.save!

    expect(created.reloaded_attribute2.first.url).to eq('http://google.com')
  end
end
