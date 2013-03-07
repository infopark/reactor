# -*- encoding : utf-8 -*-
module Reactor

  class Sower
    def initialize(filename)
      @filename = filename
    end
    def sow
      require @filename
    end
  end

end

class SeedObject < RailsConnector::AbstractObj
end

module RailsConnector
  class AbstractObj

    attr_accessor :keep_edited

    def self.plant(path, &block)
      obj = Obj.find_by_path(path)
      raise ActiveRecord::RecordNotFound.new('plant: Ground not found:' +path) if obj.nil?
      #obj.objClass = 'Container' # TODO: enable it!
      #obj.save!
      #obj.release!
      obj.send(:reload_attributes)
      obj.instance_eval(&block) if block_given?
      # ActiveRecord is incompatible with changing the obj class, therefore you get RecordNotFound
      begin
        obj.save!
      rescue ActiveRecord::RecordNotFound
      end
      obj.release unless obj.keep_edited || !Obj.last.edited?
      obj
    end

    # creates of fetches an obj with given name (within context),
    # executes a block on it (instance_eval)
    # saves and releases (unless keep_edited = true was called)
    # the object afterwards
    def obj(name, objClass = 'Container', &block)
      obj = Obj.find_by_path(File.join(self.path.to_s, name.to_s))
      if obj.nil?
        obj = Obj.create(:name => name, :parent => self.path, :obj_class => objClass)
      else
        obj = Obj.find_by_path(File.join(self.path.to_s, name.to_s))
        if obj.obj_class != objClass
          obj.obj_class = objClass
          begin
            obj.save!
          rescue ActiveRecord::RecordNotFound
          end
          obj = Obj.find_by_path(File.join(self.path.to_s, name.to_s))
        end
      end
      obj.send(:reload_attributes, objClass)
      obj.instance_eval(&block) if block_given?
      obj.save!
      obj.release unless obj.keep_edited || !Obj.last.edited?
      obj
    end

    def self.with(path, objClass = 'Container', &block)
      splitted_path = path.split('/')
      name = splitted_path.pop
      # ensure path exists
      (splitted_path.length).times do |i|
        subpath = splitted_path[0,(i+1)].join('/').presence || '/'
        subpath_parent = splitted_path[0,i].join('/').presence || '/'
        subpath_name = splitted_path[i]
        create(:name => subpath_name, :parent => subpath_parent, :obj_class => 'Container') unless Obj.find_by_path(subpath) unless subpath_name.blank?
      end
      parent_path = splitted_path.join('/').presence || '/'
      parent = Obj.find_by_path(parent_path)
      parent.obj(name, objClass, &block)
    end

    def do_not_release!
      @keep_edited = true
    end

    def t(key, opts={})
      I18n.t(key, opts)
    end

  end
end
