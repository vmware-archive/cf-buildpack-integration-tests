require 'bundler/setup'
require 'rspec/core'

$: << File.expand_path("..", __FILE__)
$: << File.expand_path("../../lib", __FILE__)

require 'machete'
require 'cloud_foundry'
require 'helpers/upstream_helper'

RSpec::Matchers.define :be_staged do | |
  match do |app|
    app.staged?
  end

  failure_message_for_should do |app|
    "App is not staged. Logs are:\n" +
        app.logs
  end
end

`mkdir -p log`
Machete.logger = Machete::Logger.new("log/integration.log")

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.before(:suite) do
    CloudFoundry.upstream_helper.check_test_dependencies
    Machete::Firewall.setup
  end

  config.after(:suite) do
    Machete::Firewall.teardown
  end

  config.before(:each, :null_buildpack) do
    CloudFoundry.upstream_helper.setup_language_buildpack :null
  end

  config.before(:each, :ruby_buildpack) do
    CloudFoundry.upstream_helper.setup_language_buildpack :ruby
  end

  config.before(:each, :go_buildpack) do
    CloudFoundry.upstream_helper.setup_language_buildpack :go
  end

  config.before(:each, :node_buildpack) do
    CloudFoundry.upstream_helper.setup_language_buildpack :nodejs
  end

  config.before(:each, :python_buildpack) do
    CloudFoundry.upstream_helper.setup_language_buildpack :python
  end

  config.before(:each) do
    @pwd = Dir.pwd
  end

  config.after(:each) do
    Dir.chdir @pwd
  end
end
