require "steno"

require "grape"

module Steno
end

class Steno::HttpHandler < Grape::API
  format :json

  resource :loggers do
    get :levels do
      Steno.logger_level_snapshot
    end

    put :levels do
      missing = [:regexp, :level].select { |p| !params.key?(p) }.map(&:to_s)

      if !missing.empty?
        error!("Missing query parameters: #{missing}", 400)
      end

      regexp = nil
      begin
        regexp = Regexp.new(params[:regexp])
      rescue => e
        error!("Invalid regexp", 400)
      end

      level = params[:level].to_sym
      if !Steno::Logger::LEVELS.key?(level)
        levels = Steno::Logger::LEVELS.keys.map(&:to_s)
        error!("Unknown level: #{level}. Supported levels are: #{levels}", 400)
      end

      Steno.set_logger_regexp(regexp, level)

      "ok"
    end
  end
end
