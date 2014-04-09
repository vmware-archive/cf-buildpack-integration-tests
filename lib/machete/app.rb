require 'httparty'
require 'machete/system_helper'
require 'pry'

module Machete
  class App
    include SystemHelper

    attr_reader :output, :app_name

    def initialize(app_name, language, opts={})
      @app_name = app_name
      @language = language
      @cmd = opts.fetch(:cmd, '')
      @with_pg = opts.fetch(:with_pg, false)
    end

    def push()
      Dir.chdir(app_path)
      run_cmd("cf delete -f #{app_name}")
      if @with_pg
        run_cmd("cf push #{app_name} --no-start -b #{buildpack_name}")
        run_cmd("cf bind-service #{app_name} lilelephant")
        command = "cf start #{app_name} "
      else
        command = "cf push #{app_name} -b #{buildpack_name}"
      end
      @output = run_cmd(command)
    end

    def homepage_html
      HTTParty.get("http://#{url}").body
    end

    def url
      run_cmd("cf app #{app_name} | grep url").split(' ').last
    end

    private

    def buildpack_name
      "#{@language}-test-buildpack"
    end

    def app_path
      if @language == :go
        "test_applications/go/src/#{app_name}"
      else
        "test_applications/ruby/#{app_name}"
      end
    end
  end
end
