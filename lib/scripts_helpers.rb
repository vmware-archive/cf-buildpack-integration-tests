$: << File.expand_path("..", __FILE__)
require 'cloud_foundry'

def dns_addr
  @dns_addr ||=
      with_vagrant_env { `vagrant ssh -c "sudo ip -f inet addr" 2>&1 | grep eth0 | grep inet`.split(" ")[1].gsub(/\d+\/\d+$/, "0/24") }
end

def action(*actions)
  actions.each do |action|
    CloudFoundry.logger.info "-----> #{action}"
  end
end

if ENV['VAGRANT_CWD']
  VAGRANT_CWD = ENV['VAGRANT_CWD']
else
  VAGRANT_CWD = "#{ENV['HOME']}/workspace/bosh-lite/"
  action "No VAGRANT_CWD, using default: #{ENV['VAGRANT_CWD']}"
end

def set_vagrant_working_directory
  # this is local to the clean env - thats why it seems strange that we set it often.
  ENV['VAGRANT_CWD'] = VAGRANT_CWD
end

def with_vagrant_env
  Bundler.with_clean_env do
    set_vagrant_working_directory
    yield
  end
end


def select_default_masquerade_rules(rules)
  rules.select do |rule|
    rule[:target] == 'MASQUERADE' &&
        rule[:source] == '10.244.0.0/19' &&
        rule[:destination] == '!10.244.0.0/19'
  end
end

def select_dns_only_rules(rules)
  rules.select do |rule|
    rule[:target] == 'MASQUERADE' &&
        rule[:source] == '10.244.0.0/19' &&
        rule[:destination] == dns_addr
  end
end

def save_iptables
  action "Saving iptables to #{iptables_file}"
  with_vagrant_env do
    `vagrant ssh -c "sudo iptables-save > #{iptables_file}" 2>&1`
  end
end

def restore_iptables
  action "Restoring iptables from #{iptables_file}"
  with_vagrant_env do
    `vagrant ssh -c "sudo iptables-restore #{iptables_file}" 2>&1`
  end
end

def iptables_file
  "/tmp/iptables_for_integration_spec.ipt"
end

def masquerade_dns_only
  action 'Adding DNS masquerading rule'
  with_vagrant_env do
    CloudFoundry.logger.info `vagrant ssh -c "sudo iptables -t nat -A warden-postrouting -s 10.244.0.0/19 -d #{dns_addr} -j MASQUERADE" 2>&1`
  end
end

def open_firewall_for_appdirect
  host = URI.parse(ENV['APPDIRECT_URL']).host
  `vagrant ssh -c "sudo iptables -t nat -A warden-postrouting -s 10.244.0.0/19 -d #{host} -j MASQUERADE " 2>&1`
end

def open_firewall_for_elephantsql
  host = URI.parse(ENV['DATABASE_URL']).host
  `vagrant ssh -c "sudo iptables -t nat -A warden-postrouting -s 10.244.0.0/19 -d #{host} -j MASQUERADE " 2>&1`
end
