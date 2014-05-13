require 'bundler/setup'
require 'rspec/core'

$: << File.expand_path("..", __FILE__)
$: << File.expand_path("../../lib", __FILE__)

require 'machete'
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
  upstream_helper = UpstreamHelper.new

  config.before(:each, :null_buildpack) do
    upstream_helper.setup_language_buildpack :null
  end

  config.before(:each, :ruby_buildpack) do
    upstream_helper.setup_language_buildpack :ruby
  end

end
