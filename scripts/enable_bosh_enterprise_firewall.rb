#!/usr/bin/env ruby
$: << './lib'
require 'bundler/setup'
require 'machete'

Machete::Logger.logger.info '----> Enterprise firewall emulation for bosh'
Machete::Logger.logger.info '----> Enabling firewall'

Machete::Firewall.save_iptables

Machete::Firewall.masquerade_dns_only
Machete::Firewall.open_firewall_for_appdirect
Machete::Firewall.open_firewall_for_elephantsql

