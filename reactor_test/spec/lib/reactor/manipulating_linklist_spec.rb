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

  context "inconsistent titles" do
    before do
      @obj = TestClassWithCustomAttributes.create!(:parent => '/', :name => 'test_obj_for_linklist_manipulation',
        :test_attr_linklist => [{:url => 'http://google.com'}, {:url => 'http://yahoo.com', :title => 'with title'}]
      )
    end

    after do
      @obj.destroy
    end

    describe "swap links" do
      it "stores titles properly" do
        expect(@obj.test_attr_linklist.first.title).to be_nil
        expect(@obj.test_attr_linklist.first.url).to eq('http://google.com')

        expect(@obj.test_attr_linklist.last.title).to eq('with title')
        expect(@obj.test_attr_linklist.last.url).to eq('http://yahoo.com')

        @obj.test_attr_linklist = [{:url => 'http://google.com'}, {:url => 'http://yahoo.com', :title => 'with title'}].reverse
        @obj.save!


        expect(@obj.test_attr_linklist.first.title).to eq('with title')
        expect(@obj.test_attr_linklist.first.url).to eq('http://yahoo.com')

        expect(@obj.test_attr_linklist.last.title).to be_nil
        expect(@obj.test_attr_linklist.last.url).to eq('http://google.com')
      end
    end
  end

  context "without persisting" do
    describe "removing a link" do
      it "should leave one link" do
        expect(@obj.test_attr_linklist.size).to eq(2)
        @obj.test_attr_linklist.delete_at(1)
        expect(@obj.test_attr_linklist.size).to eq(1)
      end

      it "removes given link" do
        @obj.test_attr_linklist.delete_at(1)
        expect(@obj.test_attr_linklist.first).to be_external
      end
    end

    describe "adding a link" do
      it "should append new link" do
        @obj.test_attr_linklist << 'http://yahoo.com'
        expect(@obj.test_attr_linklist.last.url).to eq('http://yahoo.com')
      end
    end

    describe "adding a link with title" do
      it "should append new link" do
        @obj.test_attr_linklist << {:title => 'yahoo', :url => 'http://yahoo.com' }
        expect(@obj.test_attr_linklist.last.url).to eq('http://yahoo.com')
        expect(@obj.test_attr_linklist.last.title).to eq('yahoo')
      end
    end
  end

  context "with persisting" do
    context "released object" do
      before do
        @obj.release!
      end

      describe "rewriting list" do
        it "rewrites successfully" do
          @obj.test_attr_linklist = [{:title => 'yahoo', :url => 'http://yahoo.com' }]
          @obj.save!
          expect(@obj.test_attr_linklist.size).to eq(1)
          expect(@obj.test_attr_linklist.first.url).to eq('http://yahoo.com')
        end
      end
    end

    describe "removing a link" do
      it "should leave one link" do
        @obj.test_attr_linklist.delete_at(1)
        expect {
          @obj.save!
        }.not_to change { @obj.test_attr_linklist.first.id }
        expect(@obj.test_attr_linklist.size).to eq(1)
      end

      it "removes given link" do
        @obj.test_attr_linklist.delete_at(1)
        @obj.save!
        expect(@obj.test_attr_linklist.first).to be_external
      end
    end

    describe "removing all links" do
      it "should leave no links" do
        @obj.test_attr_linklist = []
        @obj.save!
        expect(@obj.test_attr_linklist.size).to eq(0)
      end
    end

    describe "removing all links with ''" do
      it "should leave no links" do
        @obj.test_attr_linklist = ''
        @obj.save!
        expect(@obj.test_attr_linklist.size).to eq(0)
      end
    end

    describe "removing all links with nil" do
      it "should leave no links" do
        @obj.test_attr_linklist = nil
        @obj.save!
        expect(@obj.test_attr_linklist.size).to eq(0)
      end
    end

    describe "adding a link" do
      it "should append new link" do
        @obj.test_attr_linklist << 'http://yahoo.com'
        expect {
          expect(@obj.test_attr_linklist).to be_changed
          @obj.save!
        }.not_to change { @obj.test_attr_linklist.first(2).map(&:id) }
        expect(@obj.test_attr_linklist.last.url).to eq('http://yahoo.com')
      end
    end

    describe "adding a link with title" do
      it "should append new link" do
         @obj.test_attr_linklist << {:title => 'yahoo', :url => 'http://yahoo.com' }
         expect {
           @obj.save!
         }.not_to change { @obj.test_attr_linklist.first(2).map(&:id) }
         expect(@obj.test_attr_linklist.last.url).to eq('http://yahoo.com')
         expect(@obj.test_attr_linklist.last.title).to eq('yahoo')
      end
    end
  end
end
