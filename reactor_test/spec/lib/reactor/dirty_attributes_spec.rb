require 'spec_helper'

shared_examples "dirty attribute tracking" do |attribute, old_value, new_value|

  it "tracks changes of #{attribute}" do
    expect {
      subject.__send__(:"#{attribute}=", new_value)
    }.to change{subject.__send__(attribute)}.from(old_value).to(new_value)

    expect(subject.changed).to include(attribute.to_s)
    expect(subject.__send__(:"#{attribute}_changed?", to: new_value)).to be_truthy
  end
end

shared_examples "dirty attribute tracking with persistance" do |attribute, old_value, new_value|

  it "tracks changes of #{attribute}" do
    expect {
      subject.__send__(:"#{attribute}=", new_value)
      subject.save!
    }.to change{subject.__send__(attribute)}.from(old_value).to(new_value)
    if ::Rails::VERSION::MAJOR == 5 && ::Rails::VERSION::MINOR == 2
      expect(subject.attribute_previously_changed?(attribute)).to be_truthy
    end
  end
end

describe "Dirty attribute tracking", focus: false do
  after(:all) { Obj.where('path LIKE "/dirty_attr_check%"').each(&:destroy) }

  context "with new instance" do
    let(:subject) { TestClassWithCustomAttributes.new(name: 'old_name', title: 'old title', test_attr_string: 'old string') }

    describe "built-in attribute", focus: false do
      include_examples "dirty attribute tracking", :name, 'old_name', 'new_name'
    end

    describe "built-in content attribute" do
      include_examples "dirty attribute tracking", :title, 'old title', 'new title'
    end

    describe "content attribute", focus: false  do
      include_examples "dirty attribute tracking", :test_attr_string, 'old string', 'new string'
    end
  end

  context "with persisted instance" do
    before(:each) { @obj = TestClassWithCustomAttributes.create!(parent: '/', name: 'dirty_attr_check', title: 'old title', test_attr_string: 'old string') }
    after(:each) { @obj.destroy }

    let(:subject) { Obj.find(@obj.id) }

    it "has no changes initially" do
      expect(subject.changed).to be_empty
      expect(@obj.changed).to be_empty
    end

    describe "built-in attribute" do
      include_examples "dirty attribute tracking", :name, 'dirty_attr_check', 'dirty_attr_check2'
    end

    describe "built-in content attribute" do
      include_examples "dirty attribute tracking", :title, 'old title', 'new title'
    end

    describe "content attribute" do
      include_examples "dirty attribute tracking", :test_attr_string, 'old string', 'new string'
    end

  end

  context "new instance with persisting" do
    let(:subject) { TestClassWithCustomAttributes.new(parent:'/', name: 'dirty_attr_check', title: 'old title', test_attr_string: 'old string') }
    after(:each) { subject.destroy }

    describe "built-in attribute" do
      include_examples "dirty attribute tracking with persistance", :name, 'dirty_attr_check', 'dirty_attr_check2', nil
    end

    describe "built-in content attribute" do
      include_examples "dirty attribute tracking with persistance", :title, 'old title', 'new title', nil
    end

    describe "content attribute" do
      include_examples "dirty attribute tracking with persistance", :test_attr_string, 'old string', 'new string', ''
    end
  end

  context "existing instance with persisting", focus: false do
    before do
      @obj = TestClassWithCustomAttributes.create!(parent: '/', name: 'dirty_attr_check', title: 'old title', test_attr_string: 'old string')
      @obj.save!
    end

    after(:each) { @obj.destroy }

    let(:subject) { Obj.find(@obj.id) }

    it "has no changes initially" do
      expect(subject.changed).to be_empty
      expect(@obj.changed).to be_empty
    end

    describe "built-in attribute", focus: false do
      include_examples "dirty attribute tracking with persistance", :name, 'dirty_attr_check', 'dirty_attr_check2', 'dirty_attr_check'
    end

    describe "built-in content attribute" do
      include_examples "dirty attribute tracking with persistance", :title, 'old title', 'new title', 'old title'
    end

    describe "content attribute", focus: false do
      include_examples "dirty attribute tracking with persistance", :test_attr_string, 'old string', 'new string', 'old string'
    end

    context "when changing built-in attribute", focus: false do
      it "does not change irrevelant attributes" do
        expect(subject.__send__(:attribute_changed?, :name)).not_to be_truthy
        expect(subject.__send__(:attribute_changed?, :title)).not_to be_truthy
        expect(subject.__send__(:attribute_changed?, :test_attr_string)).not_to be_truthy

        subject.name = 'testtest'
        expect(subject.__send__(:attribute_changed?, :name)).to be_truthy
        expect(subject.__send__(:attribute_changed?, :title)).not_to be_truthy
        expect(subject.__send__(:attribute_changed?, :test_attr_string)).not_to be_truthy
      end
    end

    context "when changing built-in content attribute", focus: false do
      it "does not change irrevelant attributes" do
        expect(subject.__send__(:attribute_changed?, :name)).not_to be_truthy
        expect(subject.__send__(:attribute_changed?, :title)).not_to be_truthy
        expect(subject.__send__(:attribute_changed?, :test_attr_string)).not_to be_truthy

        subject.title = 'testtest'
        expect(subject.__send__(:attribute_changed?, :name)).not_to be_truthy
        expect(subject.__send__(:attribute_changed?, :title)).to be_truthy
        expect(subject.__send__(:attribute_changed?, :test_attr_string)).not_to be_truthy
      end
    end

    context "when content attribute", focus: false do
      it "does not change irrevelant attributes" do
        expect(subject.__send__(:attribute_changed?, :name)).not_to be_truthy
        expect(subject.__send__(:attribute_changed?, :title)).not_to be_truthy
        expect(subject.__send__(:attribute_changed?, :test_attr_string)).not_to be_truthy

        subject.test_attr_string = 'testtest'
        expect(subject.__send__(:attribute_changed?, :name)).not_to be_truthy
        expect(subject.__send__(:attribute_changed?, :title)).not_to be_truthy
        expect(subject.__send__(:attribute_changed?, :test_attr_string)).to be_truthy
      end
    end
  end
end
