require 'spec_helper'

describe 'Date Handling' do
  class TestClassWithCustomAttributes < Obj ; end

  before    { @obj = TestClassWithCustomAttributes.create(:name => 'date_test', :parent => '/') }
  after     { @obj.destroy }
  context "setting 'ISO' time" do
    it "parses the string and stores proper time" do
      t = Time.parse('Wed Aug 24 11:16:46 UTC 2011')
      iso = t.to_iso
      @obj.test_attr_date = iso
      @obj.test_attr_date.should == t
      # check persisted value
      @obj.save!
      @obj.test_attr_date.should == t
      # check for faulty reloads
      obj = Obj.find(@obj.obj_id)
      obj.test_attr_date.should == t
    end
  end

  context "setting proper time as string" do
    it "parses the string and stores proper time" do
      str = 'Wed Aug 24 11:16:46 UTC 2011'
      t = Time.parse(str)
      @obj.test_attr_date = str
      @obj.test_attr_date.should == t
      # check persisted value
      @obj.save!
      @obj.test_attr_date.should == t
      # check for faulty reloads
      obj = Obj.find(@obj.obj_id)
      obj.test_attr_date.should == t
    end
  end

  context "setting proper time as Time Object" do
    it "parses the string and stores proper time" do
      str = 'Wed Aug 24 11:16:46 UTC 2011'
      t = Time.parse(str)
      @obj.test_attr_date = t
      @obj.test_attr_date.should == t
      # check persisted value
      @obj.save!
      @obj.test_attr_date.should == t
      # check for faulty reloads
      obj = Obj.find(@obj.obj_id)
      obj.test_attr_date.should == t
    end
  end

  context "setting proper time as TimeWithZone Object" do
    it "parses the string and stores proper time" do
      str = 'Wed Aug 24 11:16:46 UTC 2011'
      t = Time.zone.parse(str)
      @obj.test_attr_date = t
      @obj.test_attr_date.should == t
      # check persisted value
      @obj.save!
      @obj.test_attr_date.should == t
      # check for faulty reloads
      obj = Obj.find(@obj.obj_id)
      obj.test_attr_date.should == t
    end
  end

  context "setting date to nil" do
    it "clears the date and returns nil" do
      str = 'Wed Aug 24 11:16:46 UTC 2011'
      t = Time.parse(str)
      @obj.test_attr_date = str

      @obj.test_attr_date = nil

      # check persisted value
      @obj.save!
      @obj.test_attr_date.should be_nil
      # check for faulty reloads
      obj = Obj.find(@obj.obj_id)
      obj.test_attr_date.should be_nil
    end
  end

  context "setting date to empty string" do
    it "clears the date and returns nil" do
      str = 'Wed Aug 24 11:16:46 UTC 2011'
      t = Time.parse(str)
      @obj.test_attr_date = str

      @obj.test_attr_date = ''

      # check persisted value
      @obj.save!
      @obj.test_attr_date.should be_nil
      # check for faulty reloads
      obj = Obj.find(@obj.obj_id)
      obj.test_attr_date.should be_nil
    end
  end

  # describe 'test_attr_date=' do
  #   it "sets test_attr_date" do
  #     t = Time.parse('Wed Aug 24 11:16:46 UTC 2011')
  #     obj.test_attr_date = t
  #     obj.test_attr_date.should == t
  #   end
  #   it "propagates to [:test_attr_date]" do
  #     t = Time.parse('Wed Aug 24 11:16:46 UTC 2011')
  #     obj.test_attr_date = t
  #     obj[:test_attr_date].should == t
  #   end
  # end

end