require 'spec_helper'

describe Reactor::Permission do
  describe 'root implies write read and create_children' do
    let(:obj) { Obj.find_by_path('/') }

    before do
      @group = Reactor::Cm::Group.create(:name => 'root_no_write')
      @user = Reactor::Cm::User::Internal.create('root_no_write_user', 'root_no_write')

      obj.permission.grant(:root, 'root_no_write')
    end

    after do
      @user.delete!
      @group.delete!
    end

    specify do
      Reactor::Sudo.su('root_no_write_user') do
        expect(obj.permission).to be_root
        expect(obj.permission).to be_write
        expect(obj.permission).to be_read
        expect(obj.permission).to be_create_children
      end
    end
  end
end
