module Reactor
  module Tools
    class Uploader

      attr_reader :cm_obj

      def initialize(cm_obj)
        self.cm_obj = cm_obj
      end

      # Uses streaming interface to upload data from
      # given IO stream or memory location.
      # Extension is used as basis for content detection.
      # Larger file transfers should be executed through IO
      # streams, which conserve memory.
      #
      # After the data has been successfuly transfered to
      # streaming interface it stores contentType and resulting
      # ticket into Reactor::Cm::Obj provided on initialization.
      #
      # NOTE: there is a known bug for Mac OS X: if you are
      # uploading more files (IO objects) in sequence,
      # the upload may fail randomly. For this platform
      # and this case fallback to memory streaming is used.
      def upload(data_or_io, extension)
        if (data_or_io.kind_of?IO)
          io = data_or_io
          begin
            ticket_id = stream_io(io, extension)
          rescue Errno::EINVAL => e
            if RUBY_PLATFORM.downcase.include?("darwin")
              # mac os x is such a piece of shit
              # writing to a socket can fail with EINVAL, randomly without
              # visible reason when using body_stream
              # in this case fallback to memory upload which always works (?!?!)
              Reactor::Cm::LOGGER.log "MacOS X bug detected for #{io.inspect}"
              io.rewind
              return upload(io.read, extension)
            else
              raise e
            end
          end
        else
          ticket_id = stream_data(data_or_io, extension)
        end

        cm_obj.set(:contentType, extension)
        cm_obj.set(:blob, {ticket_id=>{:encoding=>'stream'}})

        ticket_id
      end

      protected

      attr_writer :cm_obj

      # Stream into CM from memory. Used in cases when the file
      # has already been read into memory
      def stream_data(data, extension)
        response, ticket_id = (Net::HTTP.new(self.class.streaming_host, self.class.streaming_port).post('/stream', data,
          {'Content-Type' => self.class.content_type_for_ext(extension)}))

        handle_response(response, ticket_id)
      end

      # Stream directly an IO object into CM. Uses minimal memory,
      # as the IO is read in 1024B-Blocks
      def stream_io(io, extension)
        request = Net::HTTP::Post.new('/stream')
        request.body_stream = io
        request.content_length = read_io_content_length(io)
        request.content_type = self.class.content_type_for_ext(extension)

        response, ticket_id = nil, nil
        Net::HTTP.start(self.class.streaming_host, self.class.streaming_port) do |http|
          http.read_timeout = 60
          #http.set_debug_output $stderr
          response, ticket_id = http.request(request)
        end

        handle_response(response, ticket_id)
      end

      # Returns ticket_id if response if one of success (success or redirect)
      def handle_response(response, ticket_id)
        if response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
          ticket_id
        else
          nil
        end
      end

      # Returns the size of the IO stream.
      # The underlying stream must support either
      # the :stat method or be able to seek to
      # random position
      def read_io_content_length(io)
        if (io.respond_to?(:stat))
          # For files it is easy to read the filesize
          return io.stat.size
        else
          # For streams it is not. We seek to end of
          # the stream, read the position, and rewind
          # to the previous location
          old_pos = io.pos
          io.seek(0, IO::SEEK_END)
          content_length = io.pos
          io.seek(old_pos, IO::SEEK_SET)

          content_length
        end
      end

      def self.streaming_host
        Reactor::Configuration.xml_access[:host]
      end

      def self.streaming_port
        Reactor::Configuration.xml_access[:port]
      end

      # It should theoretically return correct/matching
      # mime type for given extension. But since the CM
      # accepts 'application/octet-stream', no extra logic
      # or external dependency is required.
      def self.content_type_for_ext(extension)
        'application/octet-stream'
      end
    end
  end
end