#!/usr/bin/env ruby

require "machete"


extend Machete::SystemHelper

Machete.logger.info run_on_warden("postgres_z1", "sudo su - vcap -c \"/var/vcap/packages/postgres/psql -c 'create database foo;' -p 5524\"")
