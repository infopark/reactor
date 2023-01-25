require 'spec_helper'

describe 'DateSerializer' do
  describe 'serialize' do
    it 'should return string if date is in iso format' do
      d = Reactor::Attributes::DateSerializer.new('date', '20180221121051')
      expect(d.serialize).to eq '20180221121051'
    end

    it 'shoud return iso string in UTC zone' do
      t = Time.zone.parse('20180221101051').in_time_zone('CET')
      d = Reactor::Attributes::DateSerializer.new('date', t)
      expect(d.serialize).to eq '20180221091051'
    end

    it 'should return nil if input is not valid date string' do
      d = Reactor::Attributes::DateSerializer.new('date', 'not valid time')
      expect(d.serialize).to eq nil
    end
    it 'should return corret time stamp in ISO format is input is a parsable date' do
      d = Reactor::Attributes::DateSerializer.new('date', 'Wed, 21 Feb 2018 10:56:38 +0100')
      expect(d.serialize).to eq '20180221095638'
    end
  end
end
