require 'spec_helper'

describe TestClassWithCustomAttributes do
  describe '.first' do
    it "does not throw error" do
      expect { described_class.first }.not_to raise_error
    end
  end
end
