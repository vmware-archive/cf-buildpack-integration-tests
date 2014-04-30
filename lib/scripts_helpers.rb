def set_vagrant_working_directory
  unless ENV['VAGRANT_CWD']
    ENV['VAGRANT_CWD']="#{ENV['HOME']}/workspace/bosh-lite/"
    action "No VAGRANT_CWD, using default: #{ENV['VAGRANT_CWD']}"
  end
end

def raw_warden_postrouting_rules
  output = `vagrant ssh -c "sudo iptables -t nat -L warden-postrouting -v -n --line-numbers"`.split("\n")
  chains = output.drop 1
  keys = chains.shift.split(/\s+/).map { |key| key.to_sym }

  chains.map do |rule|
    key_values = keys.zip(rule.split(/\s+/))
    Hash[key_values]
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
        rule[:destination] == '192.168.21.2'
  end
end

def masquerade_dns_only
  set_vagrant_working_directory

  raw_rules = raw_warden_postrouting_rules
  default_rules = select_default_masquerade_rules(raw_rules)

  if default_rules.empty?
    warn 'No default masquerading rules to remove'
  else
    remove_rule_commands = default_rules.sort_by { |rule| rule[:num] }.reverse.map do |rule|
      "sudo iptables -t nat -D warden-postrouting #{rule[:num]}"
    end.join("\n")

    action 'Removing matching rules: '
    puts remove_rule_commands

    puts `vagrant ssh -c "#{remove_rule_commands}"`
  end

  dns_only_rules = select_dns_only_rules(raw_rules)

  if dns_only_rules.empty?
    action 'Adding DNS masquerading rule'
    puts `vagrant ssh -c "sudo iptables -t nat -A warden-postrouting -s 10.244.0.0/19 -d 192.168.21.2 -j MASQUERADE"`
  else
    warn 'dns-only warden-postrouting chain already exists'
  end

  puts raw_warden_postrouting_rules
end

def reinstate_default_masquerading_rules
  set_vagrant_working_directory

  raw_rules = raw_warden_postrouting_rules
  default_rules = select_default_masquerade_rules(raw_rules)

  if default_rules.empty?
    action 'Reinstating rules: '
    puts `vagrant ssh -c "sudo iptables -t nat -A warden-postrouting -s 10.244.0.0/19 ! -d 10.244.0.0/19 -j MASQUERADE"`
  else
    warn 'Masquerading rules already exist'
  end

  dns_only_rules = select_dns_only_rules(raw_rules)

  if dns_only_rules.empty?
    warn 'Could not find DNS masquerading rule'
  else
    action 'Removing DNS masquerading rule'

    puts `vagrant ssh -c "sudo iptables -t nat -D warden-postrouting -s 10.244.0.0/19 -d 192.168.21.2 -j MASQUERADE"`
  end

  puts raw_warden_postrouting_rules

end

def action(*actions)
  actions.each do |action|
    puts "-----> #{action}"
  end
end

def warning_banner(*messages)
  warn('*' * 80)
  warn('**** WARNING')
  messages.each do |message|
    warn("**** #{message}")
  end
  warn('****')
end

def info(*messages)
  messages.each do |message|
    puts("INFO> #{message}")
  end
end