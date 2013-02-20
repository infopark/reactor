# -*- encoding : utf-8 -*-
require 'spec_helper'

describe RailsConnector::Channel do
  let(:channel_name) { 'my.simple.channel' }
  subject { described_class.find(channel_name) }

  before(:all) do
    @obj = RailsConnector::AbstractObj.create(:name => 'channel_test', :parent => '/', :obj_class => 'NewsPage')
    @obj.channels = ['my.simple.channel']

    @obj.save!
    # this will add the object to the channel
    @obj.release!
  end

  after(:all) do
    @obj.destroy
  end

  it "has one object" do
    subject.objects.should have(1).object
    subject.objects.first.id.should == @obj.id
  end

  describe '.with_prefix' do
    it "finds channels with prefix" do
      described_class.with_prefix('my.').each do |channel|
        channel.channel_name.should match(/^my\./)
      end

      described_class.with_prefix('my.').should_not be_empty
    end
  end

end
