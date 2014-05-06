require 'httparty'
require 'machete/system_helper'
require 'json'
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
      Dir.chdir("test_applications/#{@language}/#{app_name}")
      run_cmd("cf delete -f #{app_name}")
      if @with_pg
        command = "cf push #{app_name} -b #{buildpack_name}"
        command += " -c '#{@cmd}'" if @cmd
        run_cmd("#{command} --no-start")
        run_cmd("cf bind-service #{app_name} lilelephant")
        run_cmd(command)
      else
        command = "cf push #{app_name} -b #{buildpack_name}"
        command += " -c '#{@cmd}'" if @cmd
      end
      @output = run_cmd(command)

      logger.info "Output from command: #{command}\n" +
                      @output
    end

    def homepage_html
      HTTParty.get("http://#{url}").body
    end

    def url
      run_cmd("cf app #{app_name} | grep url").split(' ').last
    end

    def staged?
      raw_spaces = run_cmd('cf curl /v2/spaces')
      spaces = JSON.parse(raw_spaces)
      test_space = spaces['resources'].detect { |resource| resource['entity']['name'] == 'integration' }
      apps_url = test_space['entity']['apps_url']

      raw_apps = run_cmd("cf curl #{apps_url}")
      apps = JSON.parse(raw_apps)
      app = apps['resources'].detect { |resource| resource['entity']['name'] == app_name }
      app['entity']['package_state'] == 'STAGED'
    end

    def logs
      run_cmd("cf logs #{app_name} --recent")
    end

    private

    def buildpack_name
      "#{@language}-test-buildpack"
    end
  end
end
