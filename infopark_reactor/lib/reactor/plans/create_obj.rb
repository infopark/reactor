module Reactor
  module Plans
    class CreateObj
      def set(key, value)
        @attrs[key.to_sym] = value
      end

      def initialize(opts = {})
        @name = opts[:name]
        @parent = opts[:parent]
        @objClass = opts[:objClass]
        @attrs = {}
        @ignoreExisting = opts[:ignoreExisting]
      end

      def prepare!
        raise "#{self.class.name}: name is nil" if @name.nil?
        raise "#{self.class.name}: parent is nil" if @parent.nil?
        raise "#{self.class.name}: objClass is nil" if @objClass.nil?
        raise "#{self.class.name}: parent does not exist" unless Reactor::Cm::Obj.exists?(@parent)
        if !@ignoreExisting && Reactor::Cm::Obj.exists?(path)
          raise "#{self.class.name}: obj with name #{@name} already exists"
        end
        #         raise "#{self.class.name}: objClass #{@objClass} not found" if not Reactor::Cm::ObjClass.exists?(@objClass)
        #         @attrs.keys.each do |attr|
        #           raise "#{self.class.name}: attr #{attr} not found for objClass #{@objClass}" if not Reactor::Cm::ObjClass.has_attribute?(attr)
        #         end
        # ...?
      end

      def migrate!
        return true if @ignoreExisting && Reactor::Cm::Obj.exists?(path)

        @obj = Cm::Obj.create(@name, @parent, @objClass)
        @attrs.each do |key, value|
          @obj.set(key, value)
        end
        @obj.save!
        @obj.release!
      end

      def path
        File.join(@parent, @name)
      end
    end
  end
end
