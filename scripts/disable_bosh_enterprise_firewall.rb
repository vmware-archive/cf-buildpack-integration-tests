#!/usr/bin/env ruby
require 'bundler/setup'
require './lib/scripts_helpers'

CloudFoundry.logger.info '----> Enterprise firewall emulation for bosh'
CloudFoundry.logger.info '----> Enabling firewall'

reinstate_default_masquerading_rules

