require 'reactor/cm/object_base'

module Reactor
  module Cm
    class Channel < ObjectBase
      # Attribute definitions
      attribute :name, :except => [:set]
      attribute :title

      primary_key :name

      def self.create(name)
        super(name, {:name => name})
      end
    end
  end
end
