require "digest/md5"
require "yajl"

module Steno
end

# Transforms JSON log lines into a more human readable format
class Steno::JsonPrettifier

  attr_reader :time_format

  def initialize
    @time_format = "%Y-%m-%d %H:%M:%S.%6N"
  end

  def prettify_line(line)
    json_record = Yajl::Parser.parse(line)

    format_record(json_record)
  end

  private

  def format_record(record)
    timestamp = nil
    if record.has_key?("timestamp")
      timestamp = Time.at(record["timestamp"]).strftime(@time_format)
    else
      timestamp = "-"
    end

    log_level = nil
    if record.has_key?("log_level")
      log_level = record["log_level"].upcase
    else
      log_level = "-"
    end

    fields = [timestamp,
              record["source"] || "-",
              "pid=%s" % [record["process_id"] || "-"],
              "tid=%s" % [shortid(record["thread_id"])],
              "fid=%s" % [shortid(record["fiber_id"])],
              "%s/%s:%s" % [trim_filename(record["file"]),
                            record["method"] || "-",
                            record["lineno"] || "-"],
              format_data(record["data"]),
              "%7s" % [log_level],
              "--",
              record["message"] || "-"]

    fields.join(" ") + "\n"
  end

  def trim_filename(path)
    return "-" if path.nil?

    parts = path.split("/")

    if parts.size == 1
      parts[0]
    else
      parts.slice(-2, 2).join("/")
    end
  end

  def format_data(data = {})
    return "-" if data.empty?

    data.map { |k, v| "#{k}=#{v}" }.join(",")
  end

  def shortid(data)
    return "-" if data.nil?
    digest = Digest::MD5.hexdigest(data.to_s)
    digest[0, 4]
  end
end
