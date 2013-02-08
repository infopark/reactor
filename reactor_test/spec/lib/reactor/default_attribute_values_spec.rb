# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Default attribute values" do
  subject { TestClassWithCustomAttributes.new }

  describe 'channels' do
    specify { subject.channels.should eq([]) }
  end

  describe 'date' do
    specify { subject.test_attr_date.should eq(nil) }
  end

  describe 'enum' do
    specify { subject.test_attr_enum.should eq(nil) }
  end

  describe 'text' do
    specify { subject.test_attr_text.should eq('') }
    specify { subject.test_attr_text.should_not be_html_safe }
  end

  describe 'string' do
    specify { subject.test_attr_string.should eq('') }
    specify { subject.test_attr_string.should_not be_html_safe }
  end

  describe 'multienum' do
    specify { subject.test_attr_multienum.should eq([]) }
  end

  describe 'html' do
    specify { subject.test_attr_html.should eq('') }
    specify { subject.test_attr_html.should be_html_safe }
  end
end
