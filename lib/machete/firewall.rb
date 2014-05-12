module Machete
  module Firewall

    class << self
      def setup
        return unless BuildpackMode.offline?

        Machete.logger.action 'Bringing firewall up, bye bye internet'

        save_iptables
        masquerade_dns_only

        appdirect_url = URI.parse(ENV['APPDIRECT_URL']).host
        open_firewall_for_url(appdirect_url)
        open_firewall_for_url("babar.elephantsql.com")
      end

      def teardown
        return unless BuildpackMode.offline?

        Machete.logger.action 'Taking firewall down, internet is back'

        restore_iptables
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
        Machete.logger.action "Saving iptables to #{iptables_file}"
        run_on_host("sudo iptables-save > #{iptables_file}")
      end

      def restore_iptables
        Machete.logger.action "Restoring iptables from #{iptables_file}"
        run_on_host("sudo iptables-restore #{iptables_file}")
      end

      def iptables_file
        "/tmp/iptables_for_integration_spec.ipt"
      end

      def masquerade_dns_only
        Machete.logger.action 'Adding DNS masquerading rule'
        Machete.logger.info run_on_host("sudo iptables -t nat -A warden-postrouting -s 10.244.0.0/19 -d #{dns_addr} -j MASQUERADE")
      end

      def open_firewall_for_appdirect
        host = URI.parse(ENV['APPDIRECT_URL']).host
        run_on_host("sudo iptables -t nat -A warden-postrouting -s 10.244.0.0/19 -d #{host} -j MASQUERADE ")
      end

      def open_firewall_for_url(url)
        Machete.logger.info run_on_host("sudo iptables -t nat -A warden-postrouting -s 10.244.0.0/19 -d #{url} -j MASQUERADE ")
      end
    end
  end
end