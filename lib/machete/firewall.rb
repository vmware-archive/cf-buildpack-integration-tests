module Machete
  module Firewall
    class << self
      def disable_firewall
        restore_iptables
      end

      def enable_firewall
        save_iptables || restore_iptables

        remove_internet_bound_masquerade_rules

        masquerade_to_dns

        appdirect_url = URI.parse(ENV['APPDIRECT_URL']).host
        masquerade_to(appdirect_url)

        masquerade_to("babar.elephantsql.com")
      end

      def raw_warden_postrouting_rules
        output = with_vagrant_env do
          `vagrant ssh -c "sudo iptables -t nat -L warden-postrouting -v -n --line-numbers" 2>&1`.split("\n")
        end

        chains = output.drop 1
        keys = chains.shift.split(/\s+/).map { |key| key.to_sym }

        chains.map do |rule|
          key_values = keys.zip(rule.split(/\s+/))
          Hash[key_values]
        end
      end

      def remove_internet_bound_masquerade_rules
        raw_rules = raw_warden_postrouting_rules
        default_rules = select_default_masquerade_rules(raw_rules)

        if default_rules.empty?
          Machete.logger.error 'No default masquerading rules to remove'
          exit(1)
        elsif default_rules.length > 1
          Machete.logger.error 'Too many default masquerading rules to remove'
          Machete.logger.info default_rules.map { |rule| rule.to_s }.join("\n")
          exit(1)
        else
          remove_command = "sudo iptables -t nat -D warden-postrouting #{default_rules.first[:num]}"
          run_on_host(remove_command)
        end
      end

      def dns_addr
        @dns_addr ||= run_on_host("sudo ip -f inet addr | grep eth0 | grep inet").split(" ")[1].gsub(/\d+\/\d+$/, "0/24")
      end

      def vagrant_cwd
        return @vagrant_cwd if @vagrant_cwd

        if ENV['VAGRANT_CWD']
          @vagrant_cwd = ENV['VAGRANT_CWD']
        else
          @vagrant_cwd = "#{ENV['HOME']}/workspace/bosh-lite/"
          Machete.logger.action "No VAGRANT_CWD, using default: #{ENV['VAGRANT_CWD']}"
        end
      end

      def set_vagrant_working_directory
        # this is local to the clean env - thats why it seems strange that we set it often.
        ENV['VAGRANT_CWD'] = vagrant_cwd
      end

      def run_on_host(command)
        if in_gocd?
          `ssh -i /var/vcap/jobs/gocd_agent/id_rsa_bosh_lite ubuntu@10.10.48.64 -c "#{command}" 2>&1`
        else
          with_vagrant_env { `vagrant ssh -c "#{command}" 2>&1` }
        end
      end

      def in_gocd?
        return @in_gocd unless @in_gocd.nil?

        @in_gocd = File.exists?("/var/vcap/jobs/gocd_agent/id_rsa_bosh_lite")
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

      def save_iptables
        run_on_host("test -f #{iptables_file}")
        if $?.exitstatus == 0
          Machete.logger.info "Found existing #{iptables_file}"
          return false
        else
          Machete.logger.action "saving iptables to #{iptables_file}"
          run_on_host("sudo iptables-save > #{iptables_file}")
          return true
        end
      end

      def restore_iptables
        Machete.logger.action "Restoring iptables from #{iptables_file}"
        run_on_host("sudo iptables-restore #{iptables_file}")
      end

      def iptables_file
        "/tmp/machete_iptables.ipt"
      end

      def masquerade_to_dns
        masquerade_to(dns_addr)
      end

      def masquerade_to(destination)
        Machete.logger.action "Adding masquerading rule for destination: #{destination}"
        Machete.logger.info run_on_host("sudo iptables -t nat -A warden-postrouting -s 10.244.0.0/19 -d #{destination} -j MASQUERADE ")
      end
    end
  end
end
