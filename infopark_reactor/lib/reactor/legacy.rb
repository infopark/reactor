# -*- encoding : utf-8 -*-
module Reactor
  # This is a collection of legacy method,s that have not found any better place to live.
  module Legacy
    module Base
      def self.included(base)
        base.extend(ClassMethods)
      end

      # removes CMS objects underneath current object
      # @option options :no_children if true prevents deletion unless there are no children
      # @option options :img_children_only if true prevents deletion unless there are exclusively img children
      # @option options [Array] :children if true prevents deletion if there are other children besides the specified ones (array of names)
      def delete_children!(options={})
        # TODO: provide better discrimination mechanisms (blocks?)
        f_nochild   = options.delete(:no_children)
        f_imgchild  = options.delete(:img_children_only)
        f_children  = options.delete(:children)

        mychildren  = self.children
        image_children, other_children = mychildren.partition {|obj| obj.obj_class == 'Image'}

        # are there any links pointing to this container
        return false if has_super_links?
        # is the flag set and are there any children
        return false if f_nochild && !mychildren.empty?
        # is the flag set and are there any children besides images
        return false if f_imgchild && !other_children.empty?
        # is the flag set and are there any children besides the specified ones
        return false if f_children && !((mychildren.map(&:name) - f_children).empty?)

        # check children for any links pointing to them
        return false if mychildren.detect(&:has_super_links?)
        # check if there are any grandchildren
        return false if mychildren.detect {|child| !child.children.empty?}

        # delete children
        mychildren.each(&:destroy)
        return true
      end
    end
    module ClassMethods
      def path_from_anything(anything)
        obj_from_anything(anything).try(:path)
      end

      def obj_from_anything(anything)
        case anything
        when Fixnum then Obj.find(anything)
        when String then Obj.find_by_path(anything)
        when Obj then anything
        else raise ArgumentError, "Link target must Fixnum, String or Obj, but was #{anything.class}."
        end
      end

      def obj_id_from_anything(anything)
        obj_from_anything(anything).try(:obj_id)
      end
    end
  end
end
