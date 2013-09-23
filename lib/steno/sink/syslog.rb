unless Steno::Sink::WINDOWS
  require "steno/sink/base"

  require "singleton"
  require "thread"
  require "syslog"

  class Steno::Sink::Syslog < Steno::Sink::Base
    include Singleton

    MAX_MESSAGE_SIZE = 1024 * 3
    TRUNCATE_POSTFIX = "..."

    LOG_LEVEL_MAP = {
        :fatal  => Syslog::LOG_CRIT,
        :error  => Syslog::LOG_ERR,
        :warn   => Syslog::LOG_WARNING,
        :info   => Syslog::LOG_INFO,
        :debug  => Syslog::LOG_DEBUG,
        :debug1 => Syslog::LOG_DEBUG,
        :debug2 => Syslog::LOG_DEBUG,
    }

    def initialize
      super

      @syslog = nil
      @syslog_lock = Mutex.new
    end

    def open(identity)
      @identity = identity
      @syslog = Syslog.open(@identity, Syslog::LOG_PID, Syslog::LOG_USER)
    end

    def add_record(record)
      record = truncate_record(record)
      msg = @codec.encode_record(record)
      pri = LOG_LEVEL_MAP[record.log_level]
      @syslog_lock.synchronize { @syslog.log(pri, "%s", msg) }
    end

    def flush
      nil
    end

    private

    def truncate_record(record)
      return record if record.message.size <= MAX_MESSAGE_SIZE

      truncated = record.message.slice(0...(MAX_MESSAGE_SIZE - TRUNCATE_POSTFIX.size))
      truncated << TRUNCATE_POSTFIX
      Steno::Record.new(record.source, record.log_level,
                        truncated,
                        [record.file, record.lineno, record.method],
                        record.data)
    end
  end
end