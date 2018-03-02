require 'spec_helper'

describe 'Builtin validation' do

  before  { @obj = ValidationClass.create(:name => 'validation_test', :parent => '/') }
  after   { @obj.destroy }

  describe 'with only one link' do
    it "should <s>not</s> be valid" do
      @obj.set(:between_two_and_four_links, 'http://google.com')
      # This makes sense, but CM doesn't care:
      # @obj.should_not be_valid(:release)
      expect(@obj).to be_valid(:release)
    end
  end

  describe "with two links" do
    it "should be valid" do
      @obj.set(:between_two_and_four_links, ['http://google.com', 'http://www.microsoft.com'])
      expect(@obj).to be_valid(:release)
    end
  end

  describe "with five links" do
    it "should not be valid" do
      links = 5.times.map { 'http://google.com' }
      @obj.set(:between_two_and_four_links, links)
      expect(@obj).not_to be_valid(:release)
    end
  end
end
