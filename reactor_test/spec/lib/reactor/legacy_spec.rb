# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Reactor::Legacy do
  describe ".path_from_anything" do
    context "when given a string" do
      it "returns it" do
        Obj.path_from_anything('/object_sure_to_exist').should == '/object_sure_to_exist'
      end
    end

    context "when given an integer" do
      before do
        @obj_12345 = stub_obj(Obj, :path => "/obj/path")
        Obj.stub(:find).and_return(@obj_12345)
      end
      it "returns path of obj with matching id" do
        Obj.path_from_anything(12345).should == @obj_12345.path
      end
    end

    context "when given an Obj" do
      it "returns its path" do
        path = '/obj/path'
        Obj.path_from_anything(stub_obj(Obj, :path => path)).should == path
      end
    end

    context "when given anything else" do
      it "raises an ArgumentError" do
        class K ; end
        expect { Obj.path_from_anything(:symbol) }.to raise_error(ArgumentError)
        expect { Obj.path_from_anything(K.new) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.sanitize_name' do
    it "translates umlauts to ae, ue &c." do
      Obj.sanitize_name('Gänsefüßchen').should == 'Gaensefuesschen'
    end

    it "truncates disallowed characters" do
      Obj.sanitize_name('all_is_well?!@%^&*').should == 'all_is_well'
    end

    it "replaces multiple disallowed charactes with single underscore" do
      Obj.sanitize_name('too      many    _   spaces').should == 'too_many_spaces'
    end
  end
end
