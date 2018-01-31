require "spec_helper"

describe "Linking deactivated objects", focus: true do
  before do
    @container  = Obj.create!(name: 'linking_deactivated_objects', parent: '/', obj_class: 'PlainObjClass')
    @target     = TestClassWithCustomAttributes.create!(name: 'target', parent: @container)
    @new_target = TestClassWithCustomAttributes.create!(name: 'new_target', parent: @container)
    @source     = TestClassWithCustomAttributes.create!(name: 'source', parent: @container, test_attr_linklist: [{title: "", destination_object: @target.path}])
  end

  after do
    @source.destroy
    @new_target.destroy
    @target.destroy
    @container.destroy
  end

  specify do
    expect(@source.test_attr_linklist.length).to eq(1)
    expect(@source.attr_values["test_attr_linklist"].length).to eq(1)

    @target.update_attributes!(valid_from: 3.minutes.ago, valid_until: 2.minutes.ago)
    @target.release!

    @source.reload

    expect(@source.test_attr_linklist.length).to eq(0)
    expect(@source.attr_values["test_attr_linklist"].length).to eq(1)

    @source.update_attributes!(test_attr_linklist: [{title: "", destination_object: @new_target.path}])

    expect(@source.test_attr_linklist.length).to eq(1)
    expect(@source.attr_values["test_attr_linklist"].length).to eq(1)

    @source.reload

    expect(@source.test_attr_linklist.length).to eq(1)
    expect(@source.attr_values["test_attr_linklist"].length).to eq(1)
  end
end
