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
    @rc_obj = RailsConnector::AbstractObj.find(@obj.obj_id)
  end

  after do
    @generator.destroy!
  end

  def as(user, &block)
    Reactor::Sudo.su(user, &block)
  end

  it "Adam can forward the obj to Gert, Gert & Hans & Dirk can do only take or give" do
    as('Adam') { expect(@obj.valid_actions).to include('forward') }
    as('Gert') { expect(@obj.valid_actions).to include('give', 'take') }
    as('Hans') { expect(@obj.valid_actions).to include('give', 'take') }
    as('Dirk') { expect(@obj.valid_actions).to include('give', 'take') }
  end

  context "Adam forwards the obj to Gert, Gert takes it" do
    before do
      as('Adam') { @obj.forward!('continue') }
      as('Gert') { @obj.take!('got it') }
    end

    describe "workflow_comments" do
      it "contains the last two comments" do
        expect(@rc_obj.workflow_comments.first(2).map(&:text)).to eq(['got it', 'continue'])
      end
    end

    it "Gert can commit the obj to Hans, Adam & Hans & Dirk can do only take or give" do
      as('Adam') { expect(@obj.valid_actions).to include('give', 'take') }
      as('Gert') { expect(@obj.valid_actions).to include('commit') }
      as('Hans') { expect(@obj.valid_actions).to include('give', 'take') }
      as('Dirk') { expect(@obj.valid_actions).to include('give', 'take') }
    end
  end

  context "Adam forwards, Gert commits" do
    before do
      as('Adam') { @obj.forward!('done') }
      as('Gert') { @obj.take!('picking up') ; @obj.commit!('check') }
    end

    describe "workflow_comments" do
      it "contains the last three comments" do
        expect(@rc_obj.workflow_comments.first(3).map(&:text)).to eq(['check', 'picking up', 'done'])
      end
    end

    it "and Hans, Dirk can sign. Adam and Gert can't do anything" do
      as('Adam') { expect(@obj.valid_actions).to be_empty }
      as('Gert') { expect(@obj.valid_actions).to be_empty }
      #as('Dirk') { p @obj.valid_actions } # what with dirk?
      as('Hans') { expect(@obj.valid_actions).to include('sign') }
      as('Dirk') { expect(@obj.valid_actions).to include('sign') }
    end
  end

  context "Reactor API" do
    it "workflow is not empty" do
      expect(@rc_obj.workflow).not_to be_empty
    end

    it "Adam can forward the obj to Gert, Gert & Hans & Dirk can do only take or give" do
      as('Adam') { expect(@rc_obj.workflow).to be_forward }
      as('Gert') { expect(@rc_obj.workflow).to be_take }
      as('Hans') { expect(@rc_obj.workflow).to be_take }
      as('Dirk') { expect(@rc_obj.workflow).to be_take }
    end

    context "Adam forwards the obj to Gert, Gert takes it" do
      before do
        as('Adam') { @rc_obj.workflow.forward! }
        as('Gert') { @rc_obj.workflow.take! }
      end

      it "Gert can commit the obj to Hans, Adam & Hans & Dirk can do only take or give" do
        as('Adam') { expect(@rc_obj.workflow).to be_take }
        as('Gert') { expect(@rc_obj.workflow).to be_commit }
        as('Hans') { expect(@rc_obj.workflow).to be_take }
        as('Dirk') { expect(@rc_obj.workflow).to be_take }
      end
    end

    context "Adam forwards, Gert commits" do
      before do
        as('Adam') { @rc_obj.workflow.forward! }
        as('Gert') { @rc_obj.workflow.take! ; @rc_obj.workflow.commit! }
      end

      it "and Hans, Dirk can sign. Adam and Gert can't do anything" do
        as('Adam') { expect(@rc_obj.workflow).not_to be_take }
        as('Gert') { expect(@rc_obj.workflow).not_to be_take }
        as('Hans') { expect(@rc_obj.workflow).to be_sign }
        as('Dirk') { expect(@rc_obj.workflow).to be_sign }
      end

      context "Hans signs" do
        before do
          as('Hans') { @rc_obj.workflow.sign!('DONE') }
        end

        describe "workflow_comments" do
          it "contains the last comment" do
            expect(@rc_obj.workflow_comments.first.text).to eq('DONE')
          end
        end

        it "Dirk can release (but not sign!) and reject, others can do nothing" do
          as('Adam') { expect(@obj.valid_actions).to be_empty }
          as('Gert') { expect(@obj.valid_actions).to be_empty }
          as('Hans') { expect(@obj.valid_actions).to be_empty }

          as('Dirk') { expect(@rc_obj.workflow).not_to be_sign }
          as('Dirk') { expect(@rc_obj.workflow).to be_release }
          as('Dirk') { expect(@rc_obj.workflow).to be_reject }

          as('Adam') { expect(@rc_obj.permission.release?).to eq(false) }
          as('Gert') { expect(@rc_obj.permission.release?).to eq(false) }
          as('Hans') { expect(@rc_obj.permission.release?).to eq(false) }

          as('Dirk') { expect(@rc_obj.permission.release?).to eq(true) }
        end

        context "Dirk does not have permission write" do
          before do
            @rc_obj.permission.revoke(:write, 'Dirk_group')
          end

          it "Dirk can still release and reject" do
            as('Adam') { expect(@obj.valid_actions).to be_empty }
            as('Gert') { expect(@obj.valid_actions).to be_empty }
            as('Hans') { expect(@obj.valid_actions).to be_empty }

            as('Dirk') { expect(@rc_obj.workflow).not_to be_sign }
            as('Dirk') { expect(@rc_obj.workflow).to be_release }
            as('Dirk') { expect(@rc_obj.workflow).to be_reject }

            as('Adam') { expect(@rc_obj.permission.release?).to eq(false) }
            as('Gert') { expect(@rc_obj.permission.release?).to eq(false) }
            as('Hans') { expect(@rc_obj.permission.release?).to eq(false) }

            as('Dirk') { expect(@rc_obj.permission.release?).to eq(true) }
          end
        end
      end
    end
  end
end
