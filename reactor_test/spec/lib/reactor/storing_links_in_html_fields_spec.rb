# -*- encoding : utf-8 -*-
require 'spec_helper'

unless defined?(TestClassWithCustomAttributes)
  class TestClassWithCustomAttributes < Obj
  end
end

describe "in-content link persisting" do
  # FIXME: somehow all requests are stored and never reused
  #use_vcr_cassette "link_persisting"

  shared_examples "persistent link serializer" do
    context "given a link to existing obj" do
      it "stores an internal link" do
        obj.send(:"#{attr}=", %Q|<a href="/object_sure_to_exist">link</a> text|)
        obj.save!
        Obj.find(obj.id).send(attr).should match(/internallink:/)
      end

      context "from html-safe string" do
        it "stores an internal link" do
          obj.send(:"#{attr}=", %Q|<a href="/object_sure_to_exist">link</a> text|.html_safe)
          obj.save!
          Obj.find(obj.id).send(attr).should match(/internallink:/)
        end
      end
    end

    context "given an image tag with existing obj as source" do
      it "stores an internal link" do
        obj.send(:"#{attr}=", %Q|<img src="/object_sure_to_exist">|)
        obj.save!
        Obj.find(obj.id).send(attr).should match(/internallink:/)
      end
    end

    context "given a HTML5 image tag with existing obj as source" do
      it "stores an internal link" do
        obj.send(:"#{attr}=", %Q|<img src="/object_sure_to_exist" />|)
        obj.save!
        Obj.find(obj.id).send(attr).should match(/internallink:/)
      end
    end

    context "given a malformed HTML5 image tag with existing obj as source" do
      it "stores an internal link" do
        obj.send(:"#{attr}=", %Q|<img src="/object_sure_to_exist"/>|)
        obj.save!
        Obj.find(obj.id).send(attr).should match(/internallink:/)
      end
    end

    context "given a link to nonexistent obj" do
      it "stores an link" do
        obj.send(:"#{attr}=", %Q|<a href="/nonexistent_object">link</a> text|)
        obj.save!
        Obj.find(obj.id).send(attr).should match(/internallink:/)
      end
    end

    context "given an image tag with nonexistent obj as source" do
      it "stores an internal link" do
        obj.send(:"#{attr}=", %Q|<img src="/nonexistent_object">|)
        obj.save!
        Obj.find(obj.id).send(attr).should match(/internallink:/)
      end
    end

    context "given an external link" do
      it "stores an external link" do
        obj.send(:"#{attr}=", %Q|<a href="http://google.com">link</a> text|)
        obj.save!
        Obj.find(obj.id).send(attr).should match(/internallink:/) # YES! It stores external links with internallink: :-)
      end
    end
  end

  shared_examples "no link serialization" do
    it "doesn't write any internal links" do
      obj.send(:"#{attr}=", %Q|<a href="/object_sure_to_exist">link</a> text|)
      obj.save!
      obj.resolve_refs! # just to be extra sure, force resolve refs
      Obj.find(obj.id).send(attr).should == %Q|<a href="/object_sure_to_exist">link</a> text|
    end

    it "doesn't write any external links" do
      obj.send(:"#{attr}=", %Q|<a href="http://google.com">link</a> text|)
      obj.save!
      obj.resolve_refs! # just to be extra sure, force resolve refs
      Obj.find(obj.id).send(attr).should == %Q|<a href="http://google.com">link</a> text|
    end
  end

  describe "storing links in Obj body" do
    it_behaves_like "persistent link serializer" do
      let(:obj) { Obj.create(:name => 'link_serializer', :parent => '/', :obj_class => 'PlainObjClass')}
      let(:attr) { :body }
      after { obj.destroy }
    end
  end

  describe "storing links in TestClassWithCustomAttributes body" do
    it_behaves_like "persistent link serializer" do
      let(:obj) { TestClassWithCustomAttributes.create(:name => 'link_serializer', :parent => '/')}
      let(:attr) { :body }
      after { obj.destroy }
    end
  end

  describe "storing links in TestClassWithCustomAttributes test_attr_html" do
    it_behaves_like "persistent link serializer" do
      let(:obj) { TestClassWithCustomAttributes.create(:name => 'link_serializer', :parent => '/')}
      let(:attr) { :test_attr_html }
      after { obj.destroy }
    end
  end

  describe "storing links in TestClassWithCustomAttributes test_attr_string" do
    it_behaves_like "no link serialization" do
      let(:obj) { TestClassWithCustomAttributes.create(:name => 'link_serializer', :parent => '/')}
      let(:attr) { :test_attr_string }
      after { obj.destroy }
    end
  end

  describe "storing links in TestClassWithCustomAttributes test_attr_text" do
    it_behaves_like "no link serialization" do
      let(:obj) { TestClassWithCustomAttributes.create(:name => 'link_serializer', :parent => '/')}
      let(:attr) { :test_attr_text }
      after { obj.destroy }
    end
  end
end
