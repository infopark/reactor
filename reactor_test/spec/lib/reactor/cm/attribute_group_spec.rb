require 'spec_helper'

describe Reactor::Cm::AttributeGroup do
  ok = ['TestClassWithCustomAttributes', 'test_group']
  pk = ok.join('.')

  cleanup = proc do
    described_class.get(pk).delete! if described_class.exists?(pk)
  end

  before &cleanup
  after  &cleanup

  describe '.create' do
    it "creates an attribute group in CMS" do
      instance = described_class.create(*ok)
      expect(described_class.exists?(pk)).to be_truthy
      expect(instance.obj_class).to eq(ok.first)
      expect(instance.name).to eq(ok.last)
      instance.title = {'This is only a test' => {lang: 'de'}, 'English' => {lang: 'en'}}
      instance.save!

      instance = described_class.get(pk)
      expect(instance.obj_class).to eq(ok.first)
      expect(instance.name).to eq(ok.last)
      expect(instance.title).to eq('This is only a test')
    end
  end

  describe '#add/remove_attributes' do
    it "changes attributes" do
      instance = described_class.create(*ok)
      expect(instance.attributes).to eq([])

      instance.add_attributes(['test_attr_html', 'test_attr_string'])
      expect(instance.attributes).to eq(['test_attr_html', 'test_attr_string'])

      instance.add_attributes(['test_attr_linklist'])
      expect(instance.attributes).to eq(['test_attr_html', 'test_attr_string', 'test_attr_linklist'])

      instance.remove_attributes(['test_attr_string'])
      expect(instance.attributes).to eq(['test_attr_html', 'test_attr_linklist'])

      # reload
      instance = described_class.get(pk)
      expect(instance.attributes).to eq(['test_attr_html', 'test_attr_linklist'])

      instance.move_attribute('test_attr_linklist', 0)
      expect(instance.attributes).to eq(['test_attr_linklist', 'test_attr_html'])
    end
  end

  context "migrated attribute group" do
    it "contains migrated data" do
      instance = described_class.get('TestClassWithCustomAttributes.my_custom_group')
      expect(instance.attributes).to eq(['test_attr_string', 'test_attr_linklist'])
      expect(instance.index).to eq("1")
      expect(instance.title).to eq('Deutscher Titel')

      rc = RailsConnector::ObjClass.find_by_name('TestClassWithCustomAttributes')
      group = rc.attribute_groups[1]

      group["attributes"]
      expect(group["attributes"]).to eq(['test_attr_string', 'test_attr_linklist'])
      expect(group["title.de"]).to eq("Deutscher Titel")
      expect(group["title.en"]).to eq("English Title")
      expect(group["name"]).to eq('my_custom_group')

      group = rc.attribute_groups[2]
      group["attributes"]
      expect(group["attributes"]).to eq(['test_attr_text'])
      expect(group["title.de"]).to eq("just title")
      expect(group["title.en"]).to eq(nil)
      expect(group["name"]).to eq('another_group')

    end
  end

end
