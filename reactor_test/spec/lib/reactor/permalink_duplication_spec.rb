require 'spec_helper'

describe "Duplicated permalinks" do
  before do
    Obj.find_by_permalink('duplicate_permalink').try(:destroy)
  end

  after do
    Obj.find_by_permalink('duplicate_permalink').try(:destroy)
  end

  specify "cause error" do
    Obj.create(:obj_class => 'PlainObjClass', :name => 'duplicate_permalink', :parent => '/', :permalink => 'duplicate_permalink')
    expect { Obj.create(:obj_class => 'PlainObjClass', :name => 'duplicate_permalink', :parent => '/', :permalink => 'duplicate_permalink') }.to raise_error(Reactor::Cm::XmlRequestError)
  end
end
