#!/usr/bin/env ruby
$: << './lib'
require 'json'
require 'pry'
require 'machete'

# Example usage:
#   APPDIRECT_USERNAME=$APPDIRECT_USERNAME APPDIRECT_PASSWORD=$APPDIRECT_PASSWORD APPDIRECT_URL=$APPDIRECT_URL ./scripts/prepare_space.rb

Machete.logger.action('Logging into CF')
warn('* If this times out, check your routing to the CF API')


if `uname` == "Darwin"
  Machete.logger.action "Setting local Mac route to Bosh Lite"
  puts `sudo route delete -net 10.244.0.0/19 192.168.50.4 > /dev/null 2>&1`
  puts `sudo route add -net 10.244.0.0/19 192.168.50.4`
else
  Machete.logger.action "Setting GoCD route to Bosh Lite"
  `sudo route add -net 10.244.0.0/19 gw 10.10.48.64`
end

puts 'ROUTES: '
puts `sudo route`

Machete.logger.info("Setting CF API target")
puts `cf api api.10.244.0.34.xip.io --skip-ssl-validation`

puts `cf login -u admin -p admin -o pivotal -s integration`

Machete.logger.action('Creating space')
puts `cf create-org pivotal`
puts `cf create-space integration -o pivotal`
puts `cf target -o pivotal -s integration`

Machete.logger.action('Adding Service Broker')

unless ENV['APPDIRECT_USERNAME'] && ENV['APPDIRECT_PASSWORD'] && ENV['APPDIRECT_URL']
  Machete.logger.warn(
    'You must provide the APPDIRECT_[USERNAME|PASSWORD|URL] environment variables'
  )
end

puts `cf create-service-broker appdirect #{ENV['APPDIRECT_USERNAME']} #{ENV['APPDIRECT_PASSWORD']} #{ENV['APPDIRECT_URL']}`

if !$?.success?
  Machete.logger.info 'appdirect service already installed'
else
  Machete.logger.info 'appdirect service installed'
end

raw_services = `cf curl /v2/services?q=label:elephantsql`
services = JSON.parse(raw_services)

service_plans_url = services['resources'].first['entity']['service_plans_url']
raw_plans = `cf curl #{service_plans_url}`
plans = JSON.parse(raw_plans)
free_plan = plans['resources'].detect { |plan| plan['entity']['free'] }
free_plan_url = free_plan['metadata']['url']

raw_free_plan_update = `cf curl #{free_plan_url} -X PUT -d '{"public":true}'`
free_plan_update = JSON.parse(raw_free_plan_update)

if !free_plan_update['entity']['public']
  warn 'failed to make elephantsql public'
  exit 1
end

Machete.logger.info 'elephantsql free plan is now public'

Machete.logger.info `cf create-service elephantsql turtle lilelephant`
