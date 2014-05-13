require 'machete/matchers/app_staged'
require 'rspec/core'

RSpec.configure do |config|
  config.before(:suite) do
    Machete::RSpecHelpers.check_test_dependencies
    Machete::RSpecHelpers.setup
  end

  config.after(:suite) do
    Machete::RSpecHelpers.teardown
  end
end

module Machete
  module RSpecHelpers
    class << self
      def check_test_dependencies
        services = `cf services`

        unless services =~ /^lilelephant/
          Machete.logger.warn("Could not find 'lilelephant' service in current cf space")
          Machete.logger.warn('Output was: ')
          Machete.logger.warn(services)
          exit(1)
        end
      end

      def setup
        return unless BuildpackMode.offline?

        Machete.logger.action 'Bringing firewall up, bye bye internet'
        Machete::Firewall.enable_firewall
      end

      def teardown
        return unless BuildpackMode.offline?

        Machete.logger.action 'Taking firewall down, internet is back'
        Machete::Firewall.disable_firewall
      end
    end
  end
end