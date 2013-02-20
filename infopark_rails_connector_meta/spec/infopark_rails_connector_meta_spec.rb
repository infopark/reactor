# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

#describe "InfoparkRailsConnectorMeta" do

describe Obj do
  it "should include RailsConnector::Meta::Base" do
    Obj.should include(RailsConnector::Meta::Base)
  end

  it "should handle Objs with and without Ruby class correctly" do
    nil.should be_false   # we're off a good start

    # everything should be false here
    obj = RailsConnector::AbstractObj.where(:obj_class => 'ObjClassWithoutRubyClass').first
    obj.obj_class_def.has_custom_ruby_class?.should be_false
    obj.has_custom_ruby_class?.should be_false
    obj.class.is_custom_ruby_class?.should be_false

    # everything should be true here
    obj2 = StandardPage.first
    obj2.obj_class_def.has_custom_ruby_class?.should be_true
    obj2.has_custom_ruby_class?.should be_true
    obj2.class.is_custom_ruby_class?.should be_true
  end

  it "should respond to obj_class_def/obj_class_definition correctly" do
    obj = RailsConnector::AbstractObj.where(:obj_class => 'ObjClassWithoutRubyClass').first
    obj.obj_class_def.name.should == 'ObjClassWithoutRubyClass'
    obj.obj_class_definition.name.should == 'ObjClassWithoutRubyClass'

    lambda { obj.class.obj_class_def }.should raise_error(RuntimeError)
    lambda { obj.class.obj_class_definition }.should raise_error(RuntimeError)

    obj2 = StandardPage.first
    obj2.obj_class_def.name.should == 'StandardPage'
    obj2.obj_class_definition.name.should == 'StandardPage'

    obj2.class.obj_class_def.name.should == 'StandardPage'
    obj2.class.obj_class_definition.name.should == 'StandardPage'
  end


end

describe RailsConnector::ObjClass do

  it "should serve the proper Ruby class" do
    obj_class_def = RailsConnector::ObjClass.where(:obj_class_name => 'ObjClassWithoutRubyClass').first
    obj_class_def.ruby_class.should == RailsConnector::AbstractObj.obj_class_def.ruby_class.should == ::Obj
    obj_class_def.has_custom_ruby_class?.should be_false

    obj2_class_def = RailsConnector::ObjClass.where(:obj_class_name => 'StandardPage').first
    obj2_class_def.ruby_class.should == StandardPage
    obj2_class_def.has_custom_ruby_class?.should be_true
  end

  it "caches blob data" do
    RailsConnector::ObjClass.should_receive(:read_blob_data) { Hash.new }.once

    obj_class_def = RailsConnector::ObjClass.where(:obj_class_name => 'ObjClassWithoutRubyClass').first
    obj_class_def.titles
    obj_class_def.custom_mandatory_attributes
  end

  context "for classes with proper titles" do
    it "returns correct titles" do
      obj_class_def = RailsConnector::ObjClass.where(:obj_class_name => 'ObjClassWithoutRubyClass').first
      obj_class_def.titles.should be_kind_of(Hash)
      obj_class_def.titles.should be_kind_of(HashWithIndifferentAccess)
      obj_class_def.title('de').should == 'Vorlage ohne Ruby Klasse'
      obj_class_def.title(:en).should == 'File Format withoud Ruby Class'
    end
  end
  context "for classes without proper titles" do
    it "returns nil for titles" do
      pending
      obj_class_def = RailsConnector::ObjClass.where(:obj_class_name => 'ObjClassWithoutTitles').first
      obj_class_def.titles.should be_kind_of(Hash)
      obj_class_def.titles.should be_kind_of(HashWithIndifferentAccess)
      obj_class_def.title('de').should be_nil
    end
  end

end

  #it "gets all ObjClass objects from the database" do
  #  all = RailsConnector::ObjClass.all
  #  #puts all.map(&:name).join(', ')
  #end
