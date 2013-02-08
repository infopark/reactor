# -*- encoding : utf-8 -*-
require 'spec_helper'

describe TrivialHelper do
  describe '#rsession' do
    it 'is a Reactor::Session' do
      helper.rsession.should be_kind_of(Reactor::Session)
    end
  end
end
