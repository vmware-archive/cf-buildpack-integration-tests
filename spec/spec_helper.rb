require 'rspec/core'

$: << File.expand_path("..", __FILE__)
$: << File.expand_path("../../lib", __FILE__)

require 'machete'
require 'helpers/upstream_helper'

Machete::Logger.log_to('machete.log')

RSpec.configure do |config|
  config.before(:suite) do
    upstream_helper = UpstreamHelper.new
    upstream_helper.setup_language_buildpack :ruby
    upstream_helper.setup_language_buildpack :go
  end

  config.before(:each) do
    @pwd = Dir.pwd
  end

  config.after(:each) do
    Dir.chdir @pwd
  end
end
