# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'reactor/cm/workflow'

describe Reactor::Cm::Workflow do
  describe '.create' do
    before do
      described_class.delete!('trivialEmptyWorkflow') if described_class.exists?('trivialEmptyWorkflow')
    end
    it "creates a workflow" do
      described_class.create('trivialEmptyWorkflow')
      described_class.should be_exists('trivialEmptyWorkflow')
      described_class.delete!('trivialEmptyWorkflow')
    end

    # Make sure the test environment has been prepared corectly
    it { Reactor::Cm::Group.should be_exists('not_root_group') }

    it "creates a workflow with editGroups" do
      workflow = described_class.create('trivialEmptyWorkflow', ['not_root_group'])
      described_class.should be_exists('trivialEmptyWorkflow')
      workflow.edit_groups.should == ['not_root_group']
      described_class.delete!('trivialEmptyWorkflow')
    end
  end

  describe '.delete!' do
    before do
      described_class.create('trivialEmptyWorkflow') unless described_class.exists?('trivialEmptyWorkflow')
    end
    it "delete!s exisiting workflow" do
      described_class.delete!('trivialEmptyWorkflow')
      described_class.should_not be_exists('trivialEmptyWorkflow')
    end
  end

  describe '.exists?' do
    it "returns true for existing workkflows" do
      described_class.create('trivialEmptyWorkflow') unless described_class.exists?('trivialEmptyWorkflow')
      described_class.should be_exists('trivialEmptyWorkflow')
      described_class.delete!('trivialEmptyWorkflow')
    end

    it "returns false for nonexisiting workflows" do
      described_class.should_not be_exists('nonexistingWorkflowForSure')
    end
  end
end
