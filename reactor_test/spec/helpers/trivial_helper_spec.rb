# frozen_string_literal: true

require 'spec_helper'

describe TrivialHelper, type: :helper do
  describe '#rsession' do
    it 'is a Reactor::Session' do
      expect(helper.rsession).to be_kind_of(Reactor::Session)
    end
  end
end
