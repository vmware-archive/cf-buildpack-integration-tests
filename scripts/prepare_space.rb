#!/usr/bin/env ruby
require './lib/scripts_helpers'

action('Logging into CF')
warn('* If this times out, check your routing to the CF API')

`cf login -u admin -p admin -o pivotal -s integration`

action('Creating space')
`cf create-org pivotal`
`cf create-space integration -o pivotal`
`cf target -o pivotal -s integration`

# puts_action('Adding Service Broker')
#
# unless ENV['APPDIRECT_USERNAME'] && ENV['APPDIRECT_PASSWORD'] && ENV['APPDIRECT_URL']
#   warning_banner(
#       'You must provide AppDirect credentials:',
#       'APPDIRECT_[USERNAME|PASSWORD|URL] environment variables'
#   )
# end
#
# `cf create-service-broker appdirect #{ENV['APPDIRECT_USERNAME']} #{ENV['APPDIRECT_PASSWORD']} #{ENV['APPDIRECT_URL']}`
#
#
# cf curl /v2/services?q=label:elephantsql
#
# cf curl <url of free elephantsql plan> -X PUT -d '{"public":true}'
