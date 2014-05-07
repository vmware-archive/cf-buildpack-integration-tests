require 'machete/matchers/app_staged'
require 'rspec/core'

RSpec.configure do |config|
  config.before(:suite) do
    Machete::RSpecHelpers.check_test_dependencies
    Machete::Firewall.setup
  end

  config.after(:suite) do
    Machete::Firewall.teardown
  end
end

module Machete
  module RSpecHelpers
    def self.check_test_dependencies
      services = `cf services`

      unless services =~ /^lilelephant/
        Machete.logger.warn("Could not find 'lilelephant' service in current cf space")
        Machete.logger.warn('Output was: ')
        Machete.logger.warn(services)
        exit(1)
      end
    end

  end
end