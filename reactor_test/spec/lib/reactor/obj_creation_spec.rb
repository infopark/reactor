require 'spec_helper'

describe "Reactor::Persistence" do
  describe "Obj.new(:name, :parent, :obj_class) .. #save" do
    before(:all) { @obj = Obj.new(:name => "created_obj", :parent => "/", :obj_class => "TestClassWithCustomAttributes") ; @obj.save! }
    after(:all) { @obj.destroy }

    it "creates an obj" do
      expect(Obj).to be_exists(@obj.id)
    end

    it "creates an obj with similar name" do
      expect(@obj.name).to match(/^created_obj[0-9]*$/)
    end

    it "creates an obj with matching obj_class" do
      expect(@obj.obj_class).to eq("TestClassWithCustomAttributes")
    end

    it "creates an obj under given parent" do
      expect(@obj.parent.path).to eq("/")
    end
  end

  describe "TestClassWithCustomAttributes.new(:name, :parent) .. #save" do
    before(:all) { @obj = TestClassWithCustomAttributes.new(:name => "created_obj", :parent => "/") ; @obj.save! }
    after(:all) { @obj.destroy }

    it "creates an obj" do
      expect(Obj).to be_exists(@obj.id)
    end

    it "creates an obj with similar name" do
      expect(@obj.name).to match(/^created_obj[0-9]*$/)
    end

    it "creates an obj with matching obj_class" do
      expect(@obj.obj_class).to eq("TestClassWithCustomAttributes")
    end

    it "creates an obj under given parent" do
      expect(@obj.parent.path).to eq("/")
    end
  end

  describe "TestClassWithCustomAttributes.new(:name, :parent) .. #save .. Obj.find" do
    before(:all) { @obj = TestClassWithCustomAttributes.new(:name => "created_obj", :parent => "/") ; @obj.save! ; @obj = Obj.find(@obj.id)}
    after(:all) { @obj.destroy }

    it "creates an obj with similar name" do
      expect(@obj.name).to match(/^created_obj[0-9]*$/)
    end

    it "creates an obj with matching obj_class" do
      expect(@obj.obj_class).to eq("TestClassWithCustomAttributes")
    end

    it "creates an obj under given parent" do
      expect(@obj.parent.path).to eq("/")
    end
  end

  describe "Obj.create(:name, :parent, :obj_class)" do
    before(:all) { @obj = Obj.create(:name => "created_obj", :parent => "/", :obj_class => "TestClassWithCustomAttributes") }
    after(:all) { @obj.destroy }

    it "creates an obj" do
      expect(Obj).to be_exists(@obj.id)
    end

    it "creates an obj with similar name" do
      expect(@obj.name).to match(/^created_obj[0-9]*$/)
    end

    it "creates an obj with matching obj_class" do
      expect(@obj.obj_class).to eq("TestClassWithCustomAttributes")
    end

    it "creates an obj under given parent" do
      expect(@obj.parent.path).to eq("/")
    end
  end

  describe "TestClassWithCustomAttributes.create(:name, :parent)" do
    before(:all) { @obj = TestClassWithCustomAttributes.create(:name => "created_obj", :parent => "/") }
    after(:all) { @obj.destroy }

    it "creates an obj with similar name" do
      expect(@obj.name).to match(/^created_obj[0-9]*$/)
    end

    it "creates an obj with matching obj_class" do
      expect(@obj.obj_class).to eq("TestClassWithCustomAttributes")
    end

    it "creates an obj under given parent" do
      expect(@obj.parent.path).to eq("/")
    end
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
        :test_attr_date => Time.parse("2011-10-11 15:00").in_time_zone,
        :test_attr_linklist => 'http://google.com'
      }
      @obj = TestClassWithCustomAttributes.create(attr_values)
    end
    after(:all) { @obj.destroy }

    it "sets test_attr_text" do
      expect(@obj[:test_attr_text]).to eq("text")
    end

    it "sets test_attr_string" do
      expect(@obj[:test_attr_string]).to eq("string")
    end

    it "sets test_attr_enum" do
      expect(@obj[:test_attr_enum]).to eq("value1")
    end

    it "sets test_attr_multienum" do
      expect(@obj[:test_attr_multienum]).to eq(["value2", "value3"])
    end

    it "sets test_attr_html" do
      expect(@obj[:test_attr_html]).to eq("<strong>html</strong>")
    end

    it "sets test_attr_date" do
      expect(@obj[:test_attr_date]).to eq(Time.parse("2011-10-11 15:00").in_time_zone)
    end

    it "sets test_attr_linklist" do
      expect(@obj[:test_attr_linklist].first.url).to eq("http://google.com")
    end
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
      expect(@obj[:test_attr_text]).to eq("text")
    end

    it "sets test_attr_string" do
      expect(@obj[:test_attr_string]).to eq("string")
    end

    it "sets test_attr_enum" do
      expect(@obj[:test_attr_enum]).to eq("value1")
    end

    it "sets test_attr_multienum" do
      expect(@obj[:test_attr_multienum]).to eq(["value2", "value3"])
    end

    it "sets test_attr_html" do
      expect(@obj[:test_attr_html]).to eq("<strong>html</strong>")
    end

    it "sets test_attr_date" do
      expect(@obj[:test_attr_date]).to eq(Time.parse("2011-10-11 15:00"))
    end

    it "sets test_attr_linklist" do
      expect(@obj[:test_attr_linklist].first.url).to eq("http://google.com")
    end

  end

end
