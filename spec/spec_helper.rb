require 'rspec/core'

$: << File.expand_path("..", __FILE__)
$: << File.expand_path("../../lib", __FILE__)

require 'machete'
require 'helpers/upstream_helper'

Machete::Logger.log_to('machete.log')


module CloudFoundry
  def self.upstream_helper
    @upstream_helper ||= UpstreamHelper.new
  end
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.before(:each, :ruby_buildpack) do
    CloudFoundry.upstream_helper.setup_language_buildpack :ruby
  end

  config.before(:each, :go_buildpack) do
    CloudFoundry.upstream_helper.setup_language_buildpack :go
  end

  config.before(:each, :node_buildpack) do
    CloudFoundry.upstream_helper.setup_language_buildpack :nodejs
  end

  config.before(:each) do
    @pwd = Dir.pwd
  end

  config.after(:each) do
    Dir.chdir @pwd
  end
end
