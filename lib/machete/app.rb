require 'httparty'
require 'machete/system_helper'

module Machete
  class App
    include SystemHelper

    attr_reader :output, :app_name

    def initialize(app_name, cmd='')
      @app_name = app_name
      @cmd = cmd
    end

    def push(with_db)
      Dir.chdir("test_applications/#{app_name}")
      run_cmd("cf delete -f #{app_name}")
      if with_db
        run_cmd("cf push #{app_name} --no-start")
        run_cmd("cf bind-service #{app_name} lilelephant")
      end
      command = "cf push #{app_name} -b ruby-integration-test"
      @output = run_cmd(command)
    end

    def homepage_html
      HTTParty.get("http://#{url}").body
    end

    def url
      run_cmd("cf app #{app_name} | grep url").split(' ').last
    end
  end
end
