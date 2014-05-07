#!/usr/bin/env ruby
$: << './lib'
require 'bundler/setup'
require 'machete'

Machete::Logger.logger.info '----> Enterprise firewall emulation for bosh'
Machete::Logger.logger.info '----> Enabling firewall'

Machete::Firewall.restore_iptables

