# -*- encoding : utf-8 -*-
require 'spec_helper'

require 'reactor/tools/workflow_generator'

# TODO: Performance!!!

# A simple workflow:
# Adam --forward--> [take] Gert --commit--> Hans --sign--> Dirk --release--> .

describe 'Reactor::Workflow' do
  before do
    @generator = Reactor::Tools::WorkflowGenerator.new(:editors => ['Adam', 'Gert'], :correctors => ['Hans', 'Dirk'])
    @generator.generate!

    @obj = @generator.obj
    @rc_obj = RailsConnector::Obj.find(@obj.obj_id)
  end

  after do
    @generator.destroy!
  end

  def as(user, &block)
    Reactor::Sudo.su(user, &block)
  end

  it "Adam can forward the obj to Gert, Gert & Hans & Dirk can do only take or give" do
    as('Adam') { @obj.valid_actions.should include('forward') }
    as('Gert') { @obj.valid_actions.should include('give', 'take') }
    as('Hans') { @obj.valid_actions.should include('give', 'take') }
    as('Dirk') { @obj.valid_actions.should include('give', 'take') }
  end

  context "Adam forwards the obj to Gert, Gert takes it" do
    before do
      as('Adam') { @obj.forward! }
      as('Gert') { @obj.take! }
    end

    it "Gert can commit the obj to Hans, Adam & Hans & Dirk can do only take or give" do
      as('Adam') { @obj.valid_actions.should include('give', 'take') }
      as('Gert') { @obj.valid_actions.should include('commit') }
      as('Hans') { @obj.valid_actions.should include('give', 'take') }
      as('Dirk') { @obj.valid_actions.should include('give', 'take') }
    end
  end

  context "Adam forwards, Gert commits" do
    before do
      as('Adam') { @obj.forward! }
      as('Gert') { @obj.take! ; @obj.commit! }
    end

    it "and Hans, Dirk can sign. Adam and Gert can't do anything" do
      as('Adam') { @obj.valid_actions.should be_empty }
      as('Gert') { @obj.valid_actions.should be_empty }
      #as('Dirk') { p @obj.valid_actions } # what with dirk?
      as('Hans') { @obj.valid_actions.should include('sign') }
      as('Dirk') { @obj.valid_actions.should include('sign') }
    end
  end

  context "Reactor API" do
    it "workflow is not empty" do
      @rc_obj.workflow.should_not be_empty
    end

    it "Adam can forward the obj to Gert, Gert & Hans & Dirk can do only take or give" do
      as('Adam') { @rc_obj.workflow.should be_forward }
      as('Gert') { @rc_obj.workflow.should be_take }
      as('Hans') { @rc_obj.workflow.should be_take }
      as('Dirk') { @rc_obj.workflow.should be_take }
    end

    context "Adam forwards the obj to Gert, Gert takes it" do
      before do
        as('Adam') { @rc_obj.workflow.forward! }
        as('Gert') { @rc_obj.workflow.take! }
      end

      it "Gert can commit the obj to Hans, Adam & Hans & Dirk can do only take or give" do
        as('Adam') { @rc_obj.workflow.should be_take }
        as('Gert') { @rc_obj.workflow.should be_commit }
        as('Hans') { @rc_obj.workflow.should be_take }
        as('Dirk') { @rc_obj.workflow.should be_take }
      end
    end

    context "Adam forwards, Gert commits" do
      before do
        as('Adam') { @rc_obj.workflow.forward! }
        as('Gert') { @rc_obj.workflow.take! ; @rc_obj.workflow.commit! }
      end

      it "and Hans, Dirk can sign. Adam and Gert can't do anything" do
        as('Adam') { @rc_obj.workflow.should_not be_take }
        as('Gert') { @rc_obj.workflow.should_not be_take }
        as('Hans') { @rc_obj.workflow.should be_sign }
        as('Dirk') { @rc_obj.workflow.should be_sign }
      end

      context "Hans signs" do
        before do
          as('Hans') { @rc_obj.workflow.sign! }
        end

        it "Dirk can release (but not sign!) and reject, others can do nothing" do
          as('Adam') { @obj.valid_actions.should be_empty }
          as('Gert') { @obj.valid_actions.should be_empty }
          as('Hans') { @obj.valid_actions.should be_empty }

          as('Dirk') { @rc_obj.workflow.should_not be_sign }
          as('Dirk') { @rc_obj.workflow.should be_release }
          as('Dirk') { @rc_obj.workflow.should be_reject }
        end
      end
    end
  end
end
