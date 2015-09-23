require 'spec_helper'

describe "multienum presets" do
  subject { Reactor::Cm::ObjClass.get('TestClassWithCustomAttributes') }

  before :all do
    attribute = Reactor::Cm::Attribute.create('multienum_preset', 'multienum')
    attribute.set(:values, ['preset', 'not_preset'])
    attribute.save!

    attribute = Reactor::Cm::Attribute.create('enum_preset', 'multienum')
    attribute.set(:values, ['epreset', 'enot_preset'])
    attribute.save!

    attribute = Reactor::Cm::Attribute.create('string_preset', 'string')
    
    obj_class = Reactor::Cm::ObjClass.get('TestClassWithCustomAttributes')
    obj_class.attributes = obj_class.attributes + ['multienum_preset', 'enum_preset', 'string_preset']
    obj_class.preset('multienum_preset', ['preset'])
    obj_class.preset('enum_preset', 'epreset')
    obj_class.preset('string_preset', 'string')
    obj_class.save!
  end

  after :all do
    obj_class = Reactor::Cm::ObjClass.get('TestClassWithCustomAttributes')
    obj_class.attributes = obj_class.attributes - ['multienum_preset', 'enum_preset', 'string_preset']
    Reactor::Cm::Attribute.get('multienum_preset').delete!
    Reactor::Cm::Attribute.get('enum_preset').delete!
    Reactor::Cm::Attribute.get('string_preset').delete!
  end

  it "reads preset correctly" do
    expect(subject.preset_attributes).to eq({"enum_preset"=>["epreset"], "string_preset"=>"string", "multienum_preset"=>["preset"]})
  end

  it "updates preset correctly" do
    subject.preset_attributes.each do |attribute, preset|
      subject.preset(attribute, preset)
    end
    subject.save!
    expect(subject.preset_attributes).to eq({"enum_preset"=>["epreset"], "string_preset"=>"string", "multienum_preset"=>["preset"]})
  end


end
