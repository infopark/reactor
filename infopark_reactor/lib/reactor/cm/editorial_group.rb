require "reactor/cm/group"

module Reactor
  module Cm
    # The EditorialGroup class respects the user management configured in the content manager and
    # handles all editorial groups. See @Group for further details.
    class EditorialGroup < Group
      primary_key :name

      protected

      # Overwritten method from +Group+.
      def base_name
        self.class.base_name
      end

      def self.base_name
        "groupProxy"
      end
    end
  end
end
