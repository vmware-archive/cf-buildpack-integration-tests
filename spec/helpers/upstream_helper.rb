require 'scripts_helpers'

class UpstreamHelper

  attr_reader :existing_buildpacks

  def initialize
    @existing_buildpacks = {}
  end

  def setup_language_buildpack(language)
    return if has_buildpack?(language)

    action("Installing buildpack for: #{language}")

    online_var = if buildpack_mode == :online
                   "ONLINE=1"
                 else
                   ""
                 end

    result = Bundler.with_clean_env do
      if File.exists?("#{File.expand_path("cf-buildpack-#{language}", buildpack_root)}/bin/package")
        package_command = "./bin/package #{buildpack_mode}"
      else
        package_command = "bundle && #{online_var} bundle exec rake package"
      end

      CloudFoundry.logger.info %x(
        cd #{File.expand_path("cf-buildpack-#{language}", buildpack_root)} &&
        rm -f #{language}_buildpack.zip &&
        #{package_command} &&
        (cf create-buildpack #{language}-test-buildpack #{language}_buildpack.zip 1 --enable &&
        cf update-buildpack #{language}-test-buildpack -p #{language}_buildpack.zip --enable) &&
        rm #{language}_buildpack.zip
      )
    end

    if $? != 0
      CloudFoundry.logger.warn "Could not create the #{language} test buildpack: \n#{result}"
      exit(false)
    end

    mark_buildpack_built(language)
  end

  def mark_buildpack_built(language)
    existing_buildpacks[language] = true
  end

  def has_buildpack?(language)
    existing_buildpacks[language]
  end

  def buildpack_mode
    @buildpack_mode ||= get_buildpack_mode
  end

  def offline?
    !online?
  end

  def online?
    get_buildpack_mode == :online
  end

  def get_buildpack_mode
    mode = (ENV['BUILDPACK_MODE'] || :online).downcase.to_sym
    CloudFoundry.logger.info("BUILDPACK_MODE not specified.\nDefaulting to '#{mode}'") unless ENV['BUILDPACK_MODE']
    mode
  end

  def buildpack_root
    @buildpack_root ||= get_buildpack_root
  end

  def get_buildpack_root
    path = ENV['BUILDPACK_ROOT'] || "../buildpacks"
    CloudFoundry.logger.info("BUILDPACK_ROOT not specified.\nDefaulting to '#{path}'") unless ENV['BUILDPACK_ROOT']
    path
  end

  def check_test_dependencies
    services = `cf services`

    unless services =~ /^lilelephant/
      CloudFoundry.logger.warn("Could not find 'lilelephant' service in current cf space")
      CloudFoundry.logger.warn('Output was: ')
      CloudFoundry.logger.warn(services)
      exit(1)
    end
  end

  def setup_firewall
    return unless offline?

    action 'Bringing firewall up, bye bye internet'

    masquerade_dns_only
    open_firewall_for_appdirect
  end

  def teardown_firewall
    return unless offline?

    action 'Taking firewall down, internet is back'

    reinstate_default_masquerading_rules
  end
end
