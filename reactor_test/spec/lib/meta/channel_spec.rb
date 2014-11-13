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
    expect(subject.objects.size).to eq(1)
    expect(subject.objects.first.id).to eq(@obj.id)
  end

  describe '.with_prefix' do
    it "finds channels with prefix" do
      described_class.with_prefix('my.').each do |channel|
        expect(channel.channel_name).to match(/^my\./)
      end

      expect(described_class.with_prefix('my.')).not_to be_empty
    end
  end

end
