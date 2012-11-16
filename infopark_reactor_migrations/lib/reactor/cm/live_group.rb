require 'reactor/cm/group'

module Reactor

  module Cm

    # The LiveGroup class respects the user management configured in the content manager and
    # handles all live groups. See @Group for further details.
    class LiveGroup < Group
      
      protected

      # Overwritten method from +Group+.
      def base_name
        'secondaryGroupProxy'
      end

    end
    
  end
  
end
