require 'logger'

module Machete
  module Logger
    def self.logger
      @logger ||= log_to
    end

    def self.log_to(file=STDOUT)
      @logger = ::Logger.new(file)
      @logger.level = ::Logger::INFO
      @logger
    end

    def logger
      Machete::Logger.logger
    end
  end
end