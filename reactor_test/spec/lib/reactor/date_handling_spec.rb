require 'spec_helper'

describe 'Date Handling' do

  shared_examples "date handling" do
    context "setting 'ISO' time as string" do
      it "parses the string and stores proper time" do
        t = Time.parse('Wed Aug 24 11:16:46 UTC 2011')
        iso = t.to_s(:number)
        @obj.test_attr_date = iso
        expect(@obj.test_attr_date.utc.change(:usec => 0)).to eq(t.change(:usec => 0))

        # check persisted value
        @obj.save!
        expect(@obj.test_attr_date.utc.change(:usec => 0)).to eq(t.change(:usec => 0))
        # check for faulty reloads
        obj = Obj.find(@obj.obj_id)
        expect(obj.test_attr_date.utc.change(:usec => 0)).to eq(t.change(:usec => 0))
      end
    end

    context "setting proper time as string" do
      it "parses the string and stores proper time" do
        str = 'Wed Aug 24 11:16:46 UTC 2011'
        t = Time.zone.parse(str).in_time_zone
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
        t = DateTime.parse(str).in_time_zone
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
        t = DateTime.parse(str).in_time_zone
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
        @obj.test_attr_date = str
        expect(@obj.test_attr_date.blank?).to be false

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
        @obj.test_attr_date = str
        expect(@obj.test_attr_date.blank?).to be false

        @obj.test_attr_date = ''

        # check persisted value
        @obj.save!
        expect(@obj.test_attr_date).to be_nil
        # check for faulty reloads
        obj = Obj.find(@obj.obj_id)
        expect(obj.test_attr_date).to be_nil
      end
    end

    describe 'test_attr_date=' do
      it "sets test_attr_date" do
        t = DateTime.parse('Wed Aug 24 11:16:46 UTC 2011').in_time_zone
        @obj.test_attr_date = t
        expect(@obj.test_attr_date).to eq t
      end
      it "propagates to [:test_attr_date]" do
        t = DateTime.parse('Wed Aug 24 11:16:46 UTC 2011').in_time_zone
        @obj.test_attr_date = t
        expect(@obj[:test_attr_date]).to eq t
      end
    end

  end

  context "with a persisted obj" do
    before    { @obj = TestClassWithCustomAttributes.create(:name => 'date_test', :parent => '/') }
    # after     { @obj.destroy }

    include_examples "date handling"
  end

  context "with a newly created obj" do
    before    { @obj = TestClassWithCustomAttributes.new(:name => 'date_test', :parent => '/') }
    # after     { @obj.destroy if @obj.persisted? }

    context "with different time zone" do
      specify "handling time zones" do

        t1 = DateTime.new(2015, 2, 2)

        expect(TestClassWithCustomAttributes.new(test_attr_date: t1).test_attr_date).not_to be_utc
      end
    end

    include_examples "date handling"
  end

  specify do
    o = TestClassWithCustomAttributes.new
    t = Time.zone.now
    o.test_attr_date = t
    expect(o.test_attr_date.to_s).to eq t.to_s
  end

end
