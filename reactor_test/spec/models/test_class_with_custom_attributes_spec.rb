# frozen_string_literal: true

require 'spec_helper'

describe TestClassWithCustomAttributes, :type => :model do
  describe '.first' do
    it "does not throw error" do
      expect { described_class.first }.not_to raise_error
    end
  end
end
