require "thread"

require "steno/logger"

module Steno
end

class Steno::LoggerDepot
  def initialize
    @loggers = {}
    @loggers_lock = Mutex.new

    @name_regex = nil
    @regex_level = nil
  end

  def get_or_set(name, logger)
    @loggers_lock.synchronize do
      @loggers[name] ||= logger
    end
  end

end
