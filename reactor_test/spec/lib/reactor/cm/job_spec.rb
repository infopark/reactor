require 'spec_helper'

describe Reactor::Cm::Job do
  describe '.create' do
    let(:job_name) { 'my_test_job' }
    let(:attributes) { Hash.new }

    before { described_class.create(job_name, attributes) }
    after  { described_class.delete!(job_name) }

    it 'creates a job with given name' do
      described_class.exists?(job_name).should be_true
    end

    it 'does not raise exception when getting created job' do
      expect { described_class.get(job_name) }.not_to raise_exception
    end

    context 'with attributes' do
      let(:attributes) do
        {
          :title => 'test title',
          :is_active => '0',
          :comment => 'super interesting job',
          :exec_login => 'not_root',
          :script => 'obj wherePath / get description',
          :schedule => [
            {:years => ['2013'], :minutes => ['11']},
            {:years => ['2012', '2014'], :minutes => ['55']}
        ]
        }
      end

      subject { described_class.get(job_name) }

      [:title, :comment, :exec_login, :script, :is_active].each do |attribute|
        it "sets #{attribute}" do
          subject.send(attribute).should eq(attributes[attribute])
        end
      end

      it "sets schedule" do
        schedule = subject.schedule
        schedule.should have(2).entries

        first = schedule.first
        second = schedule.last

        first[:years].should eq(['2013'])
        first[:minutes].should eq(['11'])

        second[:years].should eq(['2012', '2014'])
        second[:minutes].should eq(['55'])
      end
    end
  end
end
