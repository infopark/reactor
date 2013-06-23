# -*- encoding : utf-8 -*-
require 'reactor/plans/create_obj'
require 'reactor/plans/delete_obj'
require 'reactor/plans/update_obj'
require 'reactor/plans/create_obj_class'
require 'reactor/plans/delete_obj_class'
require 'reactor/plans/update_obj_class'
require 'reactor/plans/rename_obj_class'
require 'reactor/plans/create_attribute'
require 'reactor/plans/delete_attribute'
require 'reactor/plans/update_attribute'
require 'reactor/plans/create_attribute_group'
require 'reactor/plans/delete_attribute_group'
require 'reactor/plans/update_attribute_group'
require 'reactor/plans/create_group'
require 'reactor/plans/update_group'
require 'reactor/plans/delete_group'
require 'reactor/plans/rename_group'
require 'reactor/plans/create_channel'
require 'reactor/plans/delete_channel'
require 'reactor/plans/create_job'
require 'reactor/plans/update_job'
require 'reactor/plans/delete_job'

module Reactor
  class Migration
    METHODS = {
      :create_obj => Plans::CreateObj,
      :delete_obj => Plans::DeleteObj,
      :update_obj => Plans::UpdateObj,
      :create_class => Plans::CreateObjClass,
      :delete_class => Plans::DeleteObjClass,
      :update_class => Plans::UpdateObjClass,
      :rename_class => Plans::RenameObjClass,
      :create_attribute => Plans::CreateAttribute,
      :delete_attribute => Plans::DeleteAttribute,
      :update_attribute => Plans::UpdateAttribute,
      :create_attribute_group => Plans::CreateAttributeGroup,
      :delete_attribute_group => Plans::DeleteAttributeGroup,
      :update_attribute_group => Plans::UpdateAttributeGroup,
      :create_group => Plans::CreateGroup,
      :delete_group => Plans::DeleteGroup,
      :update_group => Plans::UpdateGroup,
      :rename_group => Plans::RenameGroup,
      :create_channel => Plans::CreateChannel,
      :delete_channel => Plans::DeleteChannel,
      :create_job => Plans::CreateJob,
      :delete_job => Plans::DeleteJob,
      :update_job => Plans::UpdateJob
    }

    def self.method_missing(name, *args, &block)
      if METHODS.key? name.to_sym then
        instance = init(name,*args)
        plan(instance,&block)
        prepare(instance)
        migrate(instance)
      else
        super(name, *args, &block)
      end
    end

    def self.respond_to?(name)
      METHODS.key?(name.to_sym) || super(name)
    end

    def self.contains(*args)
      @contained ||= []
      args.flatten.each do |arg|
        migration_num = arg.to_i.to_s
        @contained << migration_num
      end
    end

    def self.contained
      @contained || []
    end

    protected
    def self.init(name,*args)
      METHODS[name.to_sym].new(*args)
    end

    def self.plan(instance,&block)
      instance.instance_eval(&block) if block_given?
    end

    def self.prepare(instance)
      instance.prepare! if instance.respond_to? :prepare!
    end

    def self.migrate(instance)
      instance.migrate!
    end

    private
    def initialize ; end
  end
end
