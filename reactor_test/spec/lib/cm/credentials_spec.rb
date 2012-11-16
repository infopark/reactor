require 'spec_helper'

describe "Reactor without credentials" do
  before do
    Reactor::Configuration.xml_access[:username] = nil
  end

  after do
    Reactor::Configuration.xml_access[:username] = 'root' #removing this line will break so many tests ...
  end

  it "raises a descriptive exception" do
    expect { Obj.create(:name => 'test_obj_with_custom_attributes', :parent => '/', :obj_class => 'PlainObjClass') }.to raise_error(Reactor::Cm::MissingCredentials)
  end
end