require "spec_helper"

describe "Linking deactivated objects", focus: false do
  before do
    @container  = Obj.create!(name: 'linking_deactivated_objects', parent: '/', obj_class: 'PlainObjClass')
    @target     = TestClassWithCustomAttributes.create!(name: 'target', parent: @container, valid_from: Time.now)
    @target.reload
    @new_target = TestClassWithCustomAttributes.create!(name: 'new_target', parent: @container, valid_from: Time.now)
    @new_target.reload
    @source     = TestClassWithCustomAttributes.create!(name: 'source', parent: @container, test_attr_linklist: [{title: "", destination_object: @target.path}])
    @source.resolve_refs!
    @source.reload
  end

  after do
    @source.destroy
    @new_target.destroy
    @target.destroy
    @container.destroy
  end

  specify do
    expect(@source.attr_values["test_attr_linklist"].length).to eq(1)
    expect(@source.test_attr_linklist.length).to eq(1)

    @target.update!(valid_from: 3.minutes.ago, valid_until: 2.minutes.ago)
    @target.release!

    @source.reload

    expect(@source.test_attr_linklist.length).to eq(0)
    expect(@source.attr_values["test_attr_linklist"].length).to eq(1)

    @source.update!(test_attr_linklist: [{title: "", destination_object: @new_target.path}])

    expect(@source.test_attr_linklist.length).to eq(1)
    expect(@source.attr_values["test_attr_linklist"].length).to eq(1)

    @source.reload

    expect(@source.test_attr_linklist.length).to eq(1)
    expect(@source.attr_values["test_attr_linklist"].length).to eq(1)
  end
end
