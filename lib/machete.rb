require 'machete/logger'
require 'machete/app'
require 'machete/buildpack_uploader'
require 'machete/buildpack_mode'
require 'machete/firewall'
require 'machete/rspec_helpers'

module Machete
  class << self
    def deploy_app(app_name, language, options={}, &block)
      app = Machete::App.new(app_name, language, options)
      app.push()
      block.call(app)
    end

    def logger
      @logger ||= Machete::Logger.new(STDOUT)
    end

    def logger=(new_logger)
      @logger = new_logger
    end
  end
end

