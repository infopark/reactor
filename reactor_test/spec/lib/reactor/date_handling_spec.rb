# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'Date Handling' do
  # class TestClassWithCustomAttributes < Obj ; end


  shared_examples "date handling" do
    context "setting 'ISO' time" do
      it "parses the string and stores proper time" do
        t = Time.parse('Wed Aug 24 11:16:46 UTC 2011')
        iso = t.to_iso
        @obj.test_attr_date = iso
        expect(@obj.test_attr_date).to eq(t)
        # check persisted value
        @obj.save!
        expect(@obj.test_attr_date).to eq(t)
        # check for faulty reloads
        obj = Obj.find(@obj.obj_id)
        expect(obj.test_attr_date).to eq(t)
      end
    end

    context "setting proper time as string" do
      it "parses the string and stores proper time" do
        str = 'Wed Aug 24 11:16:46 UTC 2011'
        t = Time.parse(str)
        @obj.test_attr_date = str
        expect(@obj.test_attr_date).to eq(t)
        # check persisted value
        @obj.save!
        expect(@obj.test_attr_date).to eq(t)
        # check for faulty reloads
        obj = Obj.find(@obj.obj_id)
        expect(obj.test_attr_date).to eq(t)
      end
    end

    context "setting proper time as Time Object" do
      it "parses the string and stores proper time" do
        str = 'Wed Aug 24 11:16:46 UTC 2011'
        t = Time.parse(str)
        @obj.test_attr_date = t
        expect(@obj.test_attr_date).to eq(t)
        # check persisted value
        @obj.save!
        expect(@obj.test_attr_date).to eq(t)
        # check for faulty reloads
        obj = Obj.find(@obj.obj_id)
        expect(obj.test_attr_date).to eq(t)
      end
    end

    context "setting proper time as TimeWithZone Object" do
      it "parses the string and stores proper time" do
        str = 'Wed Aug 24 11:16:46 UTC 2011'
        t = Time.zone.parse(str)
        @obj.test_attr_date = t
        expect(@obj.test_attr_date).to eq(t)
        # check persisted value
        @obj.save!
        expect(@obj.test_attr_date).to eq(t)
        # check for faulty reloads
        obj = Obj.find(@obj.obj_id)
        expect(obj.test_attr_date).to eq(t)
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
        expect(@obj.test_attr_date).to be_nil
        # check for faulty reloads
        obj = Obj.find(@obj.obj_id)
        expect(obj.test_attr_date).to be_nil
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
        expect(@obj.test_attr_date).to be_nil
        # check for faulty reloads
        obj = Obj.find(@obj.obj_id)
        expect(obj.test_attr_date).to be_nil
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

  context "with a persisted obj" do
    before    { @obj = TestClassWithCustomAttributes.create(:name => 'date_test', :parent => '/') }
    after     { @obj.destroy }

    include_examples "date handling"
  end

  context "with a newly created obj" do
    before    { @obj = TestClassWithCustomAttributes.new(:name => 'date_test', :parent => '/') }
    after     { @obj.destroy if @obj.persisted? }

    context "with different time zone" do
      specify "handling time zones" do
        t1 = Time.new(2015, 2, 2)

        expect(TestClassWithCustomAttributes.new(test_attr_date: t1).test_attr_date).not_to be_utc
      end
    end

    include_examples "date handling"
  end

  specify do
    o = TestClassWithCustomAttributes.new
    t = Time.now
    o.test_attr_date = t
    o.test_attr_date
    expect(o.test_attr_date).to eql(t)
 end

end
