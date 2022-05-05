module Reactor
  # This module provides standard validations for Objs (:permalink, :parent_obj_id, :name, :obj_class),
  # and presence validations for all mandatory fields.
  # It also creates new validation context :release
  #
  # @todo :in validations for (multi)enums
  # @todo link validations?
  module Validations
    module Base
      def self.included(base)
        base.extend(ClassMethods)
        # Common validations for all Objs
        base.class_eval do
          validates :permalink,     format: { with: %r{\A[-_$./a-zA-Z0-9]*\Z} }
          validates :parent_obj_id, numericality: { only_integer: true }, on: :create
          validates :name,          presence: true, on: :create
          validates :obj_class,     presence: true, on: :create
        end
      end

      # Wraps around Reactor::Persistence::Base#release! and validates object
      # in :release context before release. Raises exception when invalid.
      # @raise [ActiveRecord::RecordInvalid] validations registered for :release failed
      def release!(*args)
        raise ActiveRecord::RecordInvalid, self unless valid?(:release)

        super
      end
    end

    module ClassMethods
      def inherited(subclass)
        super(subclass) # if you remove this line, y'll get TypeError: can't dup NilClass at some point

        # Add validation for each mandatory attribute
        mandatory_attrs = __mandatory_cms_attributes(subclass.name)
        mandatory_attrs&.each  do |attr|
          subclass.send(:validates_presence_of, attr.to_sym, on: :release)
        end

        cms_attributes = __cms_attributes(subclass).values
        # Add validation for linklist & multienum [minSize/maxSize]
        array_attr = %w(linklist multienum)
        array_attributes = cms_attributes.select { |attr| array_attr.include?(attr.attribute_type) }
        array_attributes.each do |attr|
          length_hash = {}
          if attr.min_size && "linklist" != attr.attribute_type
            length_hash[:minimum] = attr.min_size
          end # CMS ignores minimum for linklists.
          length_hash[:maximum] = attr.max_size if attr.max_size

          unless length_hash.empty?
            subclass.send(:validates, attr.attribute_name.to_sym, length: length_hash, on: :release)
          end
        end

        subclass
      end
    end
  end
end
