# -*- encoding : utf-8 -*-
require 'spec_helper'

unless defined?(TestClassWithCustomAttributes)
  class TestClassWithCustomAttributes < Obj
  end
end


describe "Reactor::Persistence" do
  describe "Obj.new(:name, :parent, :obj_class) .. #save" do
    before(:all) { @obj = Obj.new(:name => "created_obj", :parent => "/", :obj_class => "TestClassWithCustomAttributes") ; @obj.save! }
    after(:all) { @obj.destroy }

    it "creates an obj" do
      Obj.should be_exists(@obj.id)
    end

    it "creates an obj with similar name" do
      @obj.name.should match(/^created_obj[0-9]*$/)
    end

    it "creates an obj with matching obj_class" do
      @obj.obj_class.should == "TestClassWithCustomAttributes"
    end

    it "creates an obj under given parent" do
      @obj.parent.path.should == "/"
    end
  end

  describe "TestClassWithCustomAttributes.new(:name, :parent) .. #save" do
    before(:all) { @obj = TestClassWithCustomAttributes.new(:name => "created_obj", :parent => "/") ; @obj.save! }
    after(:all) { @obj.destroy }

    it "creates an obj" do
      Obj.should be_exists(@obj.id)
    end

    it "creates an obj with similar name" do
      @obj.name.should match(/^created_obj[0-9]*$/)
    end

    it "creates an obj with matching obj_class" do
      @obj.obj_class.should == "TestClassWithCustomAttributes"
    end

    it "creates an obj under given parent" do
      @obj.parent.path.should == "/"
    end
  end

  describe "TestClassWithCustomAttributes.new(:name, :parent) .. #save .. Obj.find" do
    before(:all) { @obj = TestClassWithCustomAttributes.new(:name => "created_obj", :parent => "/") ; @obj.save! ; @obj = Obj.find(@obj.id)}
    after(:all) { @obj.destroy }

    it "creates an obj with similar name" do
      @obj.name.should match(/^created_obj[0-9]*$/)
    end

    it "creates an obj with matching obj_class" do
      @obj.obj_class.should == "TestClassWithCustomAttributes"
    end

    it "creates an obj under given parent" do
      @obj.parent.path.should == "/"
    end
  end

  describe "Obj.create(:name, :parent, :obj_class)" do
    before(:all) { @obj = Obj.create(:name => "created_obj", :parent => "/", :obj_class => "TestClassWithCustomAttributes") }
    after(:all) { @obj.destroy }

    it "creates an obj" do
      Obj.should be_exists(@obj.id)
    end

    it "creates an obj with similar name" do
      @obj.name.should match(/^created_obj[0-9]*$/)
    end

    it "creates an obj with matching obj_class" do
      @obj.obj_class.should == "TestClassWithCustomAttributes"
    end

    it "creates an obj under given parent" do
      @obj.parent.path.should == "/"
    end
  end

  describe "TestClassWithCustomAttributes.create(:name, :parent)" do
    before(:all) { @obj = TestClassWithCustomAttributes.create(:name => "created_obj", :parent => "/") }
    after(:all) { @obj.destroy }

    it "creates an obj with similar name" do
      @obj.name.should match(/^created_obj[0-9]*$/)
    end

    it "creates an obj with matching obj_class" do
      @obj.obj_class.should == "TestClassWithCustomAttributes"
    end

    it "creates an obj under given parent" do
      @obj.parent.path.should == "/"
    end
  end

  describe "Obj.create(:name, :parent, :obj_class, :custom_attributes)" do
    pending
  end

  describe "TestClassWithCustomAttributes.create(:name, :parent, :custom_attributes)" do
    before(:all) do
      attr_values = {
        :name => "created_obj",
        :parent => "/",
        :test_attr_text => "text",
        :test_attr_string => "string",
        :test_attr_enum => "value1",
        :test_attr_multienum => ["value2", "value3"],
        :test_attr_html => "<strong>html</strong>",
        :test_attr_date => Time.parse("2011-10-11 15:00"),
        :test_attr_linklist => 'http://google.com'
      }
      @obj = TestClassWithCustomAttributes.create(attr_values)
    end
    after(:all) { @obj.destroy }

    it "sets test_attr_text" do
      @obj[:test_attr_text].should == "text"
    end

    it "sets test_attr_string" do
      @obj[:test_attr_string].should == "string"
    end

    it "sets test_attr_enum" do
      @obj[:test_attr_enum].should == "value1"
    end

    it "sets test_attr_multienum" do
      @obj[:test_attr_multienum].should == ["value2", "value3"]
    end

    it "sets test_attr_html" do
      @obj[:test_attr_html].should == "<strong>html</strong>"
    end

    it "sets test_attr_date" do
      @obj[:test_attr_date].should == Time.parse("2011-10-11 15:00")
    end

    it "sets test_attr_linklist" do
      @obj[:test_attr_linklist].first.url.should == "http://google.com"
    end
  end

  describe "Obj.new(:name, :parent, :obj_class, :custom_attributes) .. #save" do
    pending
  end

  describe "TestClassWithCustomAttributes.new(:name, :parent, :custom_attributes) .. #save" do
    before(:all) do
      attr_values = {
        :name => "created_obj",
        :parent => "/",
        :test_attr_text => "text",
        :test_attr_string => "string",
        :test_attr_enum => "value1",
        :test_attr_multienum => ["value2", "value3"],
        :test_attr_html => "<strong>html</strong>",
        :test_attr_date => Time.parse("2011-10-11 15:00"),
        :test_attr_linklist => 'http://google.com'
      }
      @obj = TestClassWithCustomAttributes.new(attr_values)
      @obj.save!
    end
    after(:all) { @obj.destroy }

    it "sets test_attr_text" do
      @obj[:test_attr_text].should == "text"
    end

    it "sets test_attr_string" do
      @obj[:test_attr_string].should == "string"
    end

    it "sets test_attr_enum" do
      @obj[:test_attr_enum].should == "value1"
    end

    it "sets test_attr_multienum" do
      @obj[:test_attr_multienum].should == ["value2", "value3"]
    end

    it "sets test_attr_html" do
      @obj[:test_attr_html].should == "<strong>html</strong>"
    end

    it "sets test_attr_date" do
      @obj[:test_attr_date].should == Time.parse("2011-10-11 15:00")
    end

    it "sets test_attr_linklist" do
      @obj[:test_attr_linklist].first.url.should == "http://google.com"
    end

  end
  
end
