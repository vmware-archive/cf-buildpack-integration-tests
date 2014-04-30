#!/usr/bin/env ruby
require './lib/scripts_helpers'

puts '----> Enterprise firewall emulation for bosh'
puts '----> Enabling firewall'

reinstate_default_masquerading_rules

