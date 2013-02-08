# -*- encoding : utf-8 -*-
require 'spec_helper'

unless defined?(TestClassWithCustomAttributes)
  class TestClassWithCustomAttributes < Obj
  end
end

describe "Object with two links set" do
  before do
    @obj = TestClassWithCustomAttributes.create!(:parent => '/', :name => 'test_obj_for_linklist_manipulation',
      :test_attr_linklist => [{:url => 'http://google.com', :title => 'mein google link'}, {:destination_object => '/object_sure_to_exist', :title => 'obj'}]
    )
  end
  after { @obj.destroy }

  context "without persisting" do
    describe "removing a link" do
      it "should leave one link" do
        @obj.test_attr_linklist.should have(2).things
        @obj.test_attr_linklist.delete_at(1)
        @obj.test_attr_linklist.should have(1).things
      end

      it "removes given link" do
        @obj.test_attr_linklist.delete_at(1)
        @obj.test_attr_linklist.first.should be_external
      end
    end

    describe "adding a link" do
      it "should append new link" do
        @obj.test_attr_linklist << 'http://yahoo.com'
        @obj.test_attr_linklist.last.url.should == 'http://yahoo.com'
      end
    end

    describe "adding a link with title" do
      it "should append new link" do
        @obj.test_attr_linklist << {:title => 'yahoo', :url => 'http://yahoo.com' }
        @obj.test_attr_linklist.last.url.should == 'http://yahoo.com'
        @obj.test_attr_linklist.last.title.should == 'yahoo'
      end
    end
  end

  context "with persisting" do
    describe "removing a link" do
      it "should leave one link" do
        @obj.test_attr_linklist.delete_at(1)
        @obj.save!
        @obj.test_attr_linklist.should have(1).things
      end

      it "removes given link" do
        @obj.test_attr_linklist.delete_at(1)
        @obj.save!
        @obj.test_attr_linklist.first.should be_external
      end
    end

    describe "removing all links" do
      it "should leave no links" do
        @obj.test_attr_linklist = []
        @obj.save!
        @obj.test_attr_linklist.should have(0).things
      end
    end

    describe "removing all links with ''" do
      it "should leave no links" do
        @obj.test_attr_linklist = ''
        @obj.save!
        @obj.test_attr_linklist.should have(0).things
      end
    end

    describe "removing all links with nil" do
      it "should leave no links" do
        @obj.test_attr_linklist = nil
        @obj.save!
        @obj.test_attr_linklist.should have(0).things
      end
    end

    describe "adding a link" do
      it "should append new link" do
        @obj.test_attr_linklist << 'http://yahoo.com'
        @obj.test_attr_linklist.should be_changed
        @obj.save!
        @obj.test_attr_linklist.last.url.should == 'http://yahoo.com'
      end
    end

    describe "adding a link with title" do
      it "should append new link" do
         @obj.test_attr_linklist << {:title => 'yahoo', :url => 'http://yahoo.com' }
         @obj.save!
         @obj.test_attr_linklist.last.url.should == 'http://yahoo.com'
         @obj.test_attr_linklist.last.title.should == 'yahoo'
      end
    end
  end
end
