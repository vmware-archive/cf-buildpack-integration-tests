#!/usr/bin/env ruby
$: << './lib'
require 'json'
require 'pry'
require 'machete'

Machete.logger.action('Creating space')
puts `cf create-org pivotal`
puts `cf create-space integration -o pivotal`
puts `cf target -o pivotal -s integration`

