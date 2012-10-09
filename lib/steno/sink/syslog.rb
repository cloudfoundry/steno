require "steno/sink/base"

require "singleton"
require "thread"
require "syslog"

class Steno::Sink::Syslog < Steno::Sink::Base
  include Singleton

  MAX_MESSAGE_SIZE = 1024 * 3

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
    record = truncate_record(record) if record.message.size > MAX_MESSAGE_SIZE
    msg = @codec.encode_record(record)
    pri = LOG_LEVEL_MAP[record.log_level.name]
    @syslog_lock.synchronize { @syslog.log(pri, "%s", msg) }
  end

  def flush
    nil
  end

  private

  def truncate_record(record)
    truncated = ""
    if MAX_MESSAGE_SIZE > 3
      truncated = record.message.slice(0..(MAX_MESSAGE_SIZE - 4))
      truncated << "..."
    end
    Steno::Record.new(record.source, record.log_level,
                      truncated,
                      [record.file, record.lineno, record.method],
                      record.data)
  end
end
