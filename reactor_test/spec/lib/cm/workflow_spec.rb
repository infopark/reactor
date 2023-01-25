# frozen_string_literal: true

require 'spec_helper'
require 'reactor/cm/workflow'

describe Reactor::Cm::Workflow do
  describe '.create' do
    before do
      described_class.delete!('trivialEmptyWorkflow') if described_class.exists?('trivialEmptyWorkflow')
    end
    it "creates a workflow" do
      described_class.create('trivialEmptyWorkflow')
      expect(described_class).to be_exists('trivialEmptyWorkflow')
      described_class.delete!('trivialEmptyWorkflow')
    end

    # Make sure the test environment has been prepared corectly
    it { expect(Reactor::Cm::Group).to be_exists('not_root_group') }

    it "creates a workflow with editGroups" do
      workflow = described_class.create('trivialEmptyWorkflow', ['not_root_group'])
      expect(described_class).to be_exists('trivialEmptyWorkflow')
      expect(workflow.edit_groups).to eq(['not_root_group'])
      described_class.delete!('trivialEmptyWorkflow')
    end
  end

  describe '.delete!' do
    before do
      described_class.create('trivialEmptyWorkflow') unless described_class.exists?('trivialEmptyWorkflow')
    end
    it "delete!s exisiting workflow" do
      described_class.delete!('trivialEmptyWorkflow')
      expect(described_class).not_to be_exists('trivialEmptyWorkflow')
    end
  end

  describe '.exists?' do
    it "returns true for existing workkflows" do
      described_class.create('trivialEmptyWorkflow') unless described_class.exists?('trivialEmptyWorkflow')
      expect(described_class).to be_exists('trivialEmptyWorkflow')
      described_class.delete!('trivialEmptyWorkflow')
    end

    it "returns false for nonexisiting workflows" do
      expect(described_class).not_to be_exists('nonexistingWorkflowForSure')
    end
  end
end
