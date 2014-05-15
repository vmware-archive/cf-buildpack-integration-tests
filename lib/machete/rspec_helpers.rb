require 'machete/matchers/app_staged'
require 'rspec/core'

RSpec.configure do |config|
  config.before(:suite) do
    if Machete::BuildpackMode.offline?
      Machete.logger.action 'Selecting OFFLINE BOSH Lite'

      offline_api_target = ENV['OFFLINE_API_TARGET'] ? ENV['OFFLINE_API_TARGET'] : 'api.10.245.0.34.xip.io'
      Machete.logger.info `cf api #{offline_api_target} --skip-ssl-validation`
    else
      Machete.logger.action 'Selecting ONLINE BOSH Lite'

      online_api_target = ENV['ONLINE_API_TARGET'] ? ENV['ONLINE_API_TARGET'] : 'api.10.244.0.34.xip.io'
      Machete.logger.info `cf api #{online_api_target} --skip-ssl-validation`
    end

    Machete.logger.action 'Logging into BOSH lite'

    Machete.logger.info `cf login -u admin -p admin`
    Machete.logger.info `cf target -o pivotal -s integration`
  end

end

