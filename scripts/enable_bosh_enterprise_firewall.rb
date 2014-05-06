#!/usr/bin/env ruby
$: << './lib'
require 'bundler/setup'
require 'scripts_helpers'

CloudFoundry.logger.info '----> Enterprise firewall emulation for bosh'
CloudFoundry.logger.info '----> Enabling firewall'

masquerade_dns_only
open_firewall_for_appdirect

