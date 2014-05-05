require 'logger'

module Machete
  module Logger
    def self.logger
      @logger ||= ::Logger.new(STDOUT)
    end

    def self.logger=(new_logger)
      @logger = new_logger
    end

    def logger
      Machete::Logger.logger
    end
  end
end