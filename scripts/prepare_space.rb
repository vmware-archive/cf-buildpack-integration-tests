#!/usr/bin/env ruby
$: << './lib'
require 'scripts_helpers'
require 'json'
require 'pry'

action('Logging into CF')
warn('* If this times out, check your routing to the CF API')

`cf login -u admin -p admin -o pivotal -s integration`

action('Creating space')
`cf create-org pivotal`
`cf create-space integration -o pivotal`
`cf target -o pivotal -s integration`

action('Adding Service Broker')

unless ENV['APPDIRECT_USERNAME'] && ENV['APPDIRECT_PASSWORD'] && ENV['APPDIRECT_URL']
  CloudFoundry.logger.warn(
      'You must provide the APPDIRECT_[USERNAME|PASSWORD|URL] environment variables'
  )
end

`cf create-service-broker appdirect #{ENV['APPDIRECT_USERNAME']} #{ENV['APPDIRECT_PASSWORD']} #{ENV['APPDIRECT_URL']}`

if !$?.success?
  CloudFoundry.logger.info 'appdirect service already installed'
else
  CloudFoundry.logger.info 'appdirect service installed'
end

raw_services = `cf curl /v2/services?q=label:elephantsql`
services = JSON.parse(raw_services)

service_plans_url = services['resources'].first['entity']['service_plans_url']
raw_plans = `cf curl #{service_plans_url}`
plans = JSON.parse(raw_plans)
free_plan = plans['resources'].first { |plan| plan['entity']['free'] }
free_plan_url = free_plan['metadata']['url']

raw_free_plan_update = `cf curl #{free_plan_url} -X PUT -d '{"public":true}'`
free_plan_update = JSON.parse(raw_free_plan_update)

if !free_plan_update['entity']['public']
  warn 'failed to make elephantsql public'
  exit 1
end

CloudFoundry.logger.info 'elephantsql free plan is now public'
