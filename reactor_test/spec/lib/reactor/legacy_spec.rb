# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Reactor::Legacy do
  describe ".path_from_anything" do
    context "when given a string" do
      it "returns it" do
        expect(Obj.path_from_anything('/object_sure_to_exist')).to eq('/object_sure_to_exist')
      end
    end

    context "when given an integer" do
      before do
        @obj_12345 = stub_obj(Obj, :path => "/obj/path")
        allow(Obj).to receive(:find).and_return(@obj_12345)
      end
      it "returns path of obj with matching id" do
        expect(Obj.path_from_anything(12345)).to eq(@obj_12345.path)
      end
    end

    context "when given an Obj" do
      it "returns its path" do
        path = '/obj/path'
        expect(Obj.path_from_anything(stub_obj(Obj, :path => path))).to eq(path)
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
      expect(Obj.sanitize_name('Gänsefüßchen')).to eq('Gaensefuesschen')
    end

    it "truncates disallowed characters" do
      expect(Obj.sanitize_name('all_is_well?!@%^&*')).to eq('all_is_well')
    end

    it "replaces multiple disallowed charactes with single underscore" do
      expect(Obj.sanitize_name('too      many    _   spaces')).to eq('too_many_spaces')
    end
  end
end
