# frozen_string_literal: true

require 'spec_helper'

describe "Reactor without credentials" do
  before do
    Reactor::Configuration.xml_access[:username] = nil
  end

  after do
    #removing this line will break so many tests ...
    Reactor::Configuration.xml_access[:username] = 'root'
  end

  it "raises a descriptive exception" do
    expect { Obj.create(:name => 'test_obj_with_custom_attributes', :parent => '/', :obj_class => 'PlainObjClass') }.to raise_error(Reactor::Cm::MissingCredentials)
  end
end
