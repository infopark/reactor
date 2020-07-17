module Reactor
  module StreamingUpload
    module Base
      # Uploads a file/string into a CM. Requires call to save afterwards(!)
      # @param [String, IO] data_or_io
      # @param [String] extension file extension
      # @raise [Reactor::UploadError] raised when CM does not respond with
      #  streaming ticket (i.e. has not accepted the file)
      # @raise [Timeout::Error] if upload to CM takes more than:
      #  60 seconds for IO streaming IO or 30 seconds for memory
      #
      # NOTE: behavior of this method is slightly different, than the
      # traditional method: this method opens a TCP connection to the CM,
      # transfers the data and stores the reference (so called streaming
      # ticket). You still need to call save! afterwards.
      def upload(data_or_io, extension)
        self.uploaded = true
        Reactor::Tools::Uploader.new(crul_obj).upload(data_or_io, extension)
      end
    end
  end
end
