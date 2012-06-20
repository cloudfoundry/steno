require "steno/sink/base"

module Steno
  module Sink
  end
end

class Steno::Sink::IO < Steno::Sink::Base
  class << self
    # Returns a new sink configured to append to the file at path.
    #
    # @param [String] path
    # @param [True, False] autoflush If true, encoded records will not be
    #   buffered by Ruby.
    #
    # @return [Steno::Sink::IO]
    def for_file(path, autoflush = true)
      io = File.open(path, "a+")

      io.sync = autoflush

      new(io)
    end
  end

  # @param [IO] io The IO object that will be written to
  # @param [Steno::Codec::Base] codec
  def initialize(io, codec = nil)
    super(codec)

    @io_lock = Mutex.new
    @io = io
  end

  def add_record(record)
    bytes = @codec.encode_record(record)

    @io_lock.synchronize { @io.write(bytes) }

    nil
  end

  def flush
    @io_lock.synchronize { @io.flush }

    nil
  end
end
