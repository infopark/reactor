require 'spec_helper'

describe Reactor::Cm::LogEntry do
  context 'object created, edited and released' do
    before(:all) do
      @obj = TestClassWithCustomAttributes.create(:name => 'logentry', :parent => '/')
      @obj.release!
      
      @logs = described_class.where(:objectId => @obj.id)
    end

    after(:all) do
      @obj.destroy
    end

    it "produces two log entries" do
      @logs.should have(2).entries
    end

    it "produces entries belonging to this object" do
      @logs.each {|entry| entry['objectId'].to_i.should eq(@obj.id) }
    end

    it "produces edit and release log" do
      @logs.map {|entry| entry['logType']}.should eq ['action_release_obj', 'action_edit_obj']
    end

    it "each entry log is complete" do
      @logs.each do |entry|
        ['logTime', 'logText', 'logType', 'objectId', 'receiver', 'userLogin'].each do |key|
          entry.should have_key(key)
        end
      end
    end

    context 'and entries cleared' do
      before(:all) do
        described_class.delete(:objectId => @obj.id)
        @logs = described_class.where(:objectId => @obj.id)
      end

      it "produces no entries" do
        @logs.should be_empty
      end
    end
  end
end
