#!/usr/bin/env ruby
require 'bundler/setup'
require './lib/scripts_helpers'

puts '----> Enterprise firewall emulation for bosh'
puts '----> Enabling firewall'

masquerade_dns_only

