# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Default attribute values" do
  subject { TestClassWithCustomAttributes.new }

  describe 'channels' do
    specify { expect(subject.channels).to eq([]) }
  end

  describe 'date' do
    specify { expect(subject.test_attr_date).to eq(nil) }
  end

  describe 'enum' do
    specify { expect(subject.test_attr_enum).to eq(nil) }
  end

  describe 'text' do
    specify { expect(subject.test_attr_text).to eq('') }
    specify { expect(subject.test_attr_text).not_to be_html_safe }
  end

  describe 'string' do
    specify { expect(subject.test_attr_string).to eq('') }
    specify { expect(subject.test_attr_string).not_to be_html_safe }
  end

  describe 'multienum' do
    specify { expect(subject.test_attr_multienum).to eq([]) }
  end

  describe 'html' do
    specify { expect(subject.test_attr_html).to eq('') }
    specify { expect(subject.test_attr_html).to be_html_safe }
  end
end
