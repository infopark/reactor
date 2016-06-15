module Reactor
  module Cm
    class BlobTooSmallError < XmlRequestError
      def initialize(msg=nil)
        super(msg ||
'The blob is too small (smaller than tuning.minStreamingDataLength) to get streaming ticket id')
      end
    end
  end
end
