# -*- encoding : utf-8 -*-
require 'spec_helper'

unless defined?(TestClassWithCustomAttributes)
  class TestClassWithCustomAttributes < Obj
  end
end

describe "link setting without persistence" do
  let(:obj) { TestClassWithCustomAttributes.create(:obj_class => 'TestClassWithCustomAttributes', :name => 'link_testbead', :parent => '/linktestbead') }
  let(:attr) { :test_attr_linklist }

  describe "setting single link" do
    it "stores only one link" do
      obj.send(:"#{attr}=", 'http://google.com')
      #obj.send(attr).should have(1).items
      obj.send(attr).length.should eq(1)
    end

    it "creates new linklist" do
      obj.send(:"#{attr}=", 'http://google.com')
      obj.send(attr).should be_kind_of(RailsConnector::LinkList)
    end

    context "(external)" do
      it "stores matching external link" do
        obj.send(:"#{attr}=", 'http://google.com')
        obj.send(attr).first.url.should == 'http://google.com'
      end
    end

    context "ftp link" do
      it "stores matching external link" do
        obj.send(:"#{attr}=", 'ftp://ftp.google.com')
        obj.send(attr).first.url.should == 'ftp://ftp.google.com'
      end
    end

    context "mailto link" do
      it "stores matching external link" do
        obj.send(:"#{attr}=", 'mailto:me@dont-write.com')
        obj.send(attr).first.url.should == 'mailto:me@dont-write.com'
      end
    end

    context "(internal)" do
      it "stores link to matching obj" do
        obj.send(:"#{attr}=", '/object_sure_to_exist')
        obj.send(attr).first.destination_object.path.should == '/object_sure_to_exist'
      end
    end

    context "with title" do
      it "stores only one link" do
        obj.send(:"#{attr}=", {:url => 'http://google.com', :title => 'Gooooooogle!'})
        #obj.send(attr).should have(1).items
        obj.send(attr).length.should eq(1)
      end

      it "stores the title" do
        obj.send(:"#{attr}=", {:url => 'http://google.com', :title => 'Gooooooogle!'})
        obj.send(attr).first.title.should eq('Gooooooogle!')
      end
    end

    context "internal link with title" do
      it "stores the link" do
        obj.send(:"#{attr}=", {:destination_object => '/object_sure_to_exist', :title => 'object_sure_to_exist!!'})
        obj.send(attr).first.destination_object.path.should == '/object_sure_to_exist'
      end
      it "stores the title" do
        obj.send(:"#{attr}=", {:destination_object => '/object_sure_to_exist', :title => 'object_sure_to_exist!!'})
        obj.send(attr).first.title.should eq('object_sure_to_exist!!')
      end
    end

    context "external link with title" do
      it "stores the link" do
        obj.send(:"#{attr}=", {:url => 'http://google.com', :title => 'object_sure_to_exist!!'})
        obj.send(attr).first.url.should == 'http://google.com'
      end
      it "stores the title" do
        obj.send(:"#{attr}=", {:url => 'http://google.com', :title => 'Gooooooogle!'})
        obj.send(attr).first.title.should eq('Gooooooogle!')
      end
    end
  end

  describe "setting two links" do
    it "stores two links" do
      obj.send(:"#{attr}=", ['http://google.com', '/object_sure_to_exist'])
      obj.send(attr).should have(2).items
    end

    it "stores matching first link" do
      obj.send(:"#{attr}=", ['http://google.com', '/object_sure_to_exist'])
      obj.send(attr).first.url.should == 'http://google.com'
    end

    it "creates new linklist" do
      obj.send(:"#{attr}=", ['http://google.com', '/object_sure_to_exist'])
      obj.send(attr).should be_kind_of(RailsConnector::LinkList)
    end

    it "stores matching second link" do
      obj.send(:"#{attr}=", ['http://google.com', '/object_sure_to_exist'])
      obj.send(attr).last.destination_object.path.should == '/object_sure_to_exist'
    end

    context "with titles" do
      before { obj.send(:"#{attr}=", [{:url => 'http://google.com', :title => 'gOOgle'}, {:destination_object => '/object_sure_to_exist', :title => 'obj!'}]) }
      it "stores two links" do
        obj.send(attr).should have(2).items
      end
      it "stores matching first link" do
        obj.send(attr).first.url.should == 'http://google.com'
      end
      it "stores matching second link" do
        obj.send(attr).last.destination_object.path.should == '/object_sure_to_exist'
      end
      it "stores matching title for first link" do
        obj.send(attr).first.title.should == 'gOOgle'
      end
      it "stores matching title for second link" do
        obj.send(attr).last.title.should == 'obj!'
      end
    end
  end
end

describe "link persisting" do
  let(:obj) { TestClassWithCustomAttributes.create(:obj_class => 'TestClassWithCustomAttributes', :name => 'link_testbead', :parent => '/linktestbead') }
  let(:attr) { :test_attr_linklist }


  describe "link store & load" do
    it "reads proper link" do
      obj.send(:"#{attr}=", 'http://google.com')
      obj.save!
      obj_copy = Obj.find(obj.obj_id)
      link = obj_copy.send(attr).first
      link.should be_external
      link.url.should == 'http://google.com'
    end
  end

  describe "setting single link" do
    it "stores only one link" do
      obj.send(:"#{attr}=", 'http://google.com')
      obj.save!
      obj.send(attr).should have(1).item
    end

    context "(external)" do
      it "stores matching external link" do
        obj.send(:"#{attr}=", 'http://google.com')
        obj.save!
        obj.send(attr).first.url.should == 'http://google.com'
      end
    end

    context "ftp link" do
      it "stores matching external link" do
        obj.send(:"#{attr}=", 'ftp://ftp.google.com')
        obj.save!
        obj.send(attr).first.url.should == 'ftp://ftp.google.com'
      end
    end

    context "mailto link" do
      it "stores matching external link" do
        obj.send(:"#{attr}=", 'mailto:me@dont-write.com')
        obj.save!
        obj.send(attr).first.url.should == 'mailto:me@dont-write.com'
      end
    end

    context "(internal)" do
      it "stores link to matching obj" do
        obj.send(:"#{attr}=", '/object_sure_to_exist')
        obj.save!
        obj.send(attr).first.destination_object.path.should == '/object_sure_to_exist'
      end
    end

    context "internal link with title" do
      it "stores the link" do
        obj.send(:"#{attr}=", {:destination_object => '/object_sure_to_exist', :title => 'object_sure_to_exist!!'})
        obj.save!
        obj.send(attr).first.destination_object.path.should == '/object_sure_to_exist'
      end
      it "stores the title" do
        obj.send(:"#{attr}=", {:destination_object => '/object_sure_to_exist', :title => 'object_sure_to_exist!!'})
        obj.save!
        obj.send(attr).first.title.should eq('object_sure_to_exist!!')
      end
    end

    context "external link with title" do
      it "stores the link" do
        obj.send(:"#{attr}=", {:url => 'http://google.com', :title => 'object_sure_to_exist!!'})
        obj.save!
        obj.send(attr).first.url.should == 'http://google.com'
      end
      it "stores the title" do
        obj.send(:"#{attr}=", {:url => 'http://google.com', :title => 'Gooooooogle!'})
        obj.save!
        obj.send(attr).first.title.should eq('Gooooooogle!')
      end
    end
  end

  describe "setting two links" do
    it "stores two links" do
      obj.send(:"#{attr}=", ['http://google.com', '/object_sure_to_exist'])
      obj.save!
      obj.send(attr).should have(2).items
    end

    it "stores matching first link" do
      obj.send(:"#{attr}=", ['http://google.com', '/object_sure_to_exist'])
      obj.save!
      obj.send(attr).first.url.should == 'http://google.com'
    end

    it "stores matching second link" do
      obj.send(:"#{attr}=", ['http://google.com', '/object_sure_to_exist'])
      obj.save!
      obj.send(attr).last.destination_object.path.should == '/object_sure_to_exist'
    end

    context "with titles" do
      before do 
        obj.send(:"#{attr}=", [
          {:url => 'http://google.com', :title => 'gOOgle'},
          {:destination_object => '/object_sure_to_exist', :title => 'obj!'}])
        obj.save!
      end
      it "stores two links" do
        obj.send(attr).should have(2).items
      end
      it "stores matching first link" do
        obj.send(attr).first.url.should == 'http://google.com'
      end
      it "stores matching second link" do
        obj.send(attr).last.destination_object.path.should == '/object_sure_to_exist'
      end
      it "stores matching title for first link" do
        obj.send(attr).first.title.should == 'gOOgle'
      end
      it "stores matching title for second link" do
        obj.send(attr).last.title.should == 'obj!'
      end
    end
  end
end

describe "link overwriting" do
  before do
    @obj = TestClassWithCustomAttributes.create(:obj_class => 'TestClassWithCustomAttributes', :name => 'link_testbead', :parent => '/linktestbead')
    @obj.test_attr_linklist = ['http://yahoo.com']
    @obj.save!
    # ensure empty caches
    @obj = Obj.find(@obj.id)
  end

  it "old link was persisted" do
    @obj.test_attr_linklist.first.url.should == 'http://yahoo.com'
  end

  describe "setting new link" do
    it "stores expected link" do
      @obj.test_attr_linklist = 'http://google.com'
      @obj.save!
      @obj.test_attr_linklist.first.url.should == 'http://google.com'
    end
  end

  describe "setting new link with title" do
    it "stores expected link" do
      @obj.test_attr_linklist = {:url => 'http://google.com', :title => 'google?'}
      @obj.save!
      @obj.test_attr_linklist.first.url.should == 'http://google.com'
      @obj.test_attr_linklist.first.title.should == 'google?'
    end
  end

end

describe "link default behavior" do
  context "when added a linklist field to existing newly created object" do
    class LinktestClass < Obj ; end
    before do
      @obj = LinktestClass.create(:parent => '/', :name => 'without_link_at_first', :test_attr_text => 'some text')
      @klass = Reactor::Cm::ObjClass.get('LinktestClass')
      @attr_name = 'test_attr_linklist'

      @klass.attributes = (@klass.attributes + [@attr_name])

      @obj.send(:reload_attributes)
      @obj.reload
    end

    after do
      @obj.destroy
      @klass.attributes = (@klass.attributes - [@attr_name])
    end

    it "should return empty array as linklist" do
      @obj.test_attr_linklist.should_not be_nil
      @obj.test_attr_linklist.should be_kind_of(Array)
    end
  end

  context "when added a linklist field to existing released and edited object" do
    class LinktestClass < Obj ; end
    before do
      @obj = LinktestClass.create(:parent => '/', :name => 'without_link_at_first', :test_attr_text => 'some text')
      @obj.release!
      @obj.edit!
      @klass = Reactor::Cm::ObjClass.get('LinktestClass')
      @attr_name = 'test_attr_linklist'

      @klass.attributes = (@klass.attributes + [@attr_name])

      @obj.send(:reload_attributes)
      @obj.reload
    end

    after do
      @obj.destroy
      @klass.attributes = (@klass.attributes - [@attr_name])
    end

    it "should return empty array as linklist" do
      @obj.test_attr_linklist.should_not be_nil
      @obj.test_attr_linklist.should be_kind_of(Array)
    end
  end

  context "when added a linklist field to existing and released(!) object" do
    class LinktestClass < Obj ; end
    before do
      @obj = LinktestClass.create(:parent => '/', :name => 'without_link_at_first', :test_attr_text => 'some text')
      @obj.release!
      @klass = Reactor::Cm::ObjClass.get('LinktestClass')
      @attr_name = 'test_attr_linklist'

      @klass.attributes = (@klass.attributes + [@attr_name])

      @obj.send(:reload_attributes)
      @obj.reload
    end

    after do
      @obj.destroy
      @klass.attributes = (@klass.attributes - [@attr_name])
    end

    it "should return empty array as linklist" do
      @obj.test_attr_linklist.should_not be_nil
      @obj.test_attr_linklist.should be_kind_of(Array)
    end
  end
end

describe "Reactor::Persistence" do
  describe "#super_objects" do
    before do
      @linking = TestClassWithCustomAttributes.create(:name => 'link_testbead', :parent => '/linktestbead')
      @linked  = TestClassWithCustomAttributes.create(:name => 'link_testbead', :parent => '/linktestbead')
      @linking.test_attr_linklist = @linked
      @linking.save!
    end

    after do
      @linking.destroy
      @linked.destroy
    end

    it "returns returns a collection of linking objects" do
      super_objects = @linked.super_objects
      super_objects.should have(1).things
      super_objects.first.obj_id.should == @linking.obj_id
    end
    
  end
  describe '#has_super_links?' do
    context "for object with superlink" do
      before do
        @linking = TestClassWithCustomAttributes.create(:name => 'link_testbead', :parent => '/linktestbead')
        @linked  = TestClassWithCustomAttributes.create(:name => 'link_testbead', :parent => '/linktestbead')
        @linking.test_attr_linklist = @linked
        @linking.save!
      end

      after do
        @linking.destroy
        @linked.destroy
      end

      it "returns true" do
        @linked.should be_has_super_links
      end
    end

    context "for object without superlinks" do
      before { @notlinked = TestClassWithCustomAttributes.create(:name => 'link_testbead', :parent => '/linktestbead') }
      after { @notlinked.destroy }
      it "returns false" do
        @notlinked.should_not be_has_super_links
      end
    end
  end
end
  
