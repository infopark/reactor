# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'Superlinks' do
  # class TestClassWithCustomAttributes < Obj ; end

  before do
    @obj      = TestClassWithCustomAttributes.create(:name => 'date_test', :parent => '/')
    @linking  = TestClassWithCustomAttributes.create(:name => 'date_test', :parent => '/', :test_attr_linklist => @obj.path)
  end

  after do
    @linking.destroy
    @obj.destroy
  end

  describe '#super_objects' do
    it "includes linking object" do
      expect(@obj.super_objects).to eq([@linking])
      expect(@linking.super_objects).to be_empty
    end
  end
end
