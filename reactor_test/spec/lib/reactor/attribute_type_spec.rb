require 'spec_helper'

unless defined?(TestClassWithCustomAttributes)
  class TestClassWithCustomAttributes < Obj
  end
end

shared_examples "attribute type reader" do
  it { obj.send(:attribute_type, attr).should == type }
end

describe "Brand new TestClassWithCustomAttributes" do
  %w{linklist date html string text enum multienum}.each do |type|
    it_should_behave_like "attribute type reader" do
      let(:obj) {TestClassWithCustomAttributes.new}
      let(:attr) {:"test_attr_#{type}"}
      let(:type) {type.to_sym}
    end
  end
end

describe "Freshly created TestClassWithCustomAttributes" do
  %w{linklist date html string text enum multienum}.each do |type|
    it_should_behave_like "attribute type reader" do
      let(:obj) { TestClassWithCustomAttributes.create(:name => 'attribute_type_tester', :parent => '/') }
      let(:attr) {:"test_attr_#{type}"}
      let(:type) {type.to_sym}
      after { obj.destroy }
    end
  end
end

describe "Freshly created and reloaded TestClassWithCustomAttributes" do
  %w{linklist date html string text enum multienum}.each do |type|
    it_should_behave_like "attribute type reader" do
      let(:obj) { o = TestClassWithCustomAttributes.create(:name => 'attribute_type_tester', :parent => '/') ; o.reload ; o }
      let(:attr) {:"test_attr_#{type}"}
      let(:type) {type.to_sym}
      after { obj.destroy }
    end
  end
end

describe "Existing TestClassWithCustomAttributes" do
  %w{linklist date html string text enum multienum}.each do |type|
    it_should_behave_like "attribute type reader" do
      let(:obj) { o = TestClassWithCustomAttributes.create(:name => 'attribute_type_tester', :parent => '/') ; o.reload ; o = Obj.find(o.id) }
      let(:attr) {:"test_attr_#{type}"}
      let(:type) {type.to_sym}
      after { obj.destroy }
    end
  end
end

describe 'Existing PlainObjClass with changed obj_class to TestClassWithCustomAttributes' do
  %w{linklist date html string text enum multienum}.each do |type|
    it_should_behave_like "attribute type reader" do
      let(:obj) do
        obj = Obj.create(:name => 'attribute_type_tester', :parent => '/', :obj_class => 'PlainObjClass')
        obj.obj_class = 'TestClassWithCustomAttributes'
        obj.save!
        obj
      end
      let(:attr) {:"test_attr_#{type}"}
      let(:type) {type.to_sym}
      after { obj.destroy }
    end
  end
end