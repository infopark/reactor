require 'spec_helper'

# :type => :routing is required for cms_id_path to work
describe "Links with anchors in html fields", :type => :routing do

  context "RailsConnector links with GET parameters" do
    before do
      @anchor = 'anchor'
      @GET = 'test=true&test2=false'
      @html = "<a href=\"#{cms_id_path(Obj.last)}?#{@GET}##{@anchor}\">link</a>"
      @obj = TestClassWithCustomAttributes.create(:name => 'source', :parent => '/', :body => @html)
      # force reload
      @obj = Obj.find(@obj.id)
    end

    after do
      [@obj].each(&:destroy)
    end

    it "link is stored properly with anchor" do
      @obj.text_links.should_not be_empty
      @obj.text_links.first.fragment.should eq(@anchor)
      @obj.text_links.first.search.should eq(@GET)
    end
  end

  context "Path links" do
    before do
      @anchor = 'anchor'
      @html = "<a href=\"#{(Obj.last).path}##{@anchor}\">link</a>"
      @obj = TestClassWithCustomAttributes.create(:name => 'source', :parent => '/', :body => @html)
      # force reload
      @obj = Obj.find(@obj.id)
    end

    after do
      [@obj].each(&:destroy)
    end

    it "link is stored properly with anchor" do
      @obj.text_links.should_not be_empty
      @obj.text_links.first.fragment.should eq(@anchor)
    end
  end

  context "Path links with get parameters" do
    include RailsConnector::DefaultCmsRoutingHelper

    before do
      @anchor = 'anchor'
      @html = "<a href=\"#{(Obj.last).path}?test=true&test2=false##{@anchor}\">link</a>"
      @obj = TestClassWithCustomAttributes.create(:name => 'source', :parent => '/', :body => @html)
      # force reload
      @obj = Obj.find(@obj.id)
    end

    after do
      [@obj].each(&:destroy)
    end

    it "link is stored properly with anchor" do
      @obj.text_links.should_not be_empty
      @obj.text_links.first.fragment.should eq(@anchor)
      @obj.text_links.first.search.should eq('test=true&test2=false')
    end
  end
end