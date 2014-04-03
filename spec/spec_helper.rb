require 'rspec/core'

$: << File.expand_path("..", __FILE__)
$: << File.expand_path("../../lib", __FILE__)

require 'machete'
require 'helpers/upstream_helper'

RSpec.configure do |config|
  config.before(:suite) do
    UpstreamHelper.setup_buildpack
  end

  config.before(:each) do
    @pwd = Dir.pwd
  end

  config.after(:each) do
    Dir.chdir @pwd
  end
end
