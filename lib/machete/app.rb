require 'httparty'
require 'machete/system_helper'

module Machete
  class App
    include SystemHelper

    attr_reader :output, :app_name

    def initialize(app_name)
      @app_name = app_name
    end

    def push
      Dir.chdir("test_applications/#{app_name}")
      @output = run_cmd("cf push #{app_name} -b ruby-integration-test")
    end

    def homepage_html
      HTTParty.get("http://#{url}").body
    end

    def url
      run_cmd("cf app #{app_name} | grep url").split(' ').last
    end
  end
end
