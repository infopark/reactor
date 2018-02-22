# -*- encoding : utf-8 -*-
require 'spec_helper'

# :type => :routing is required for cms_id_path to work
describe "Links with anchors in html fields", type: :routing do

  context "RailsConnector links with GET parameters" do
    before do
      @anchor = 'anchor'
      @GET = 'test=true&test2=false'
      @html = "<a href=\"#{cms_id_path(Obj.last)}?#{@GET}##{@anchor}\">link</a>"
      @obj = TestClassWithCustomAttributes.create(:name => 'source', :parent => '/', :body => @html, valid_from: (Time.now - 10.seconds))
      # force reload
      @obj.reload
      @obj = Obj.find(@obj.id)
    end

    after do
      [@obj].each(&:destroy)
    end

    it "link is stored propterly with anchor" do
      # @obj.text_links.should_not be_empty
      expect(@obj.text_links.empty?).to be_falsey
      expect(@obj.text_links.first.fragment).to eq(@anchor)
      expect(@obj.text_links.first.search).to eq(@GET)
    end
  end

  context "Path links" do
    before do
      @anchor = 'anchor'
      @html = "<a href=\"#{(Obj.last).path}##{@anchor}\">link</a>"
      @obj = TestClassWithCustomAttributes.create(:name => 'source', :parent => '/', :body => @html, valid_from: (Time.now - 10.seconds))
      # force reload
      @obj = Obj.find(@obj.id)
    end

    after do
      [@obj].each(&:destroy)
    end

    it "link is stored properly with anchor" do
      # @obj.text_links.should_not be_empty
      expect(@obj.text_links.empty?).to be_falsey
      expect(@obj.text_links.first.fragment).to eq(@anchor)
    end
  end

  context "Path links with get parameters" do
    include RailsConnector::DefaultCmsRoutingHelper

    before do
      @anchor = 'anchor'
      @html = "<a href=\"#{(Obj.last).path}?test=true&test2=false##{@anchor}\">link</a>"
      @obj = TestClassWithCustomAttributes.create(:name => 'source', :parent => '/', :body => @html, valid_from: (Time.now - 10.seconds))
      # force reload
      @obj = Obj.find(@obj.id)
    end

    after do
      [@obj].each(&:destroy)
    end

    it "link is stored properly with anchor" do
      # @obj.text_links.should_not be_empty
      expect(@obj.text_links.empty?).to be_falsey
      expect(@obj.text_links.first.fragment).to eq(@anchor)
      expect(@obj.text_links.first.search).to eq('test=true&test2=false')
    end
  end
end
