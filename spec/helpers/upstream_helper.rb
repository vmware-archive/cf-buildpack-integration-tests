require 'scripts_helpers'
require 'machete'

class UpstreamHelper

  attr_reader :existing_buildpacks

  def initialize
    @existing_buildpacks = {}
  end

  def setup_language_buildpack(language)
    return if has_buildpack?(language)

    Machete::BuildpackUploader.new(language, offline?)

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

    save_iptables
    masquerade_dns_only

    appdirect_url = URI.parse(ENV['APPDIRECT_URL']).host
    open_firewall_for_url(appdirect_url)
    open_firewall_for_url("babar.elephantsql.com")
  end

  def teardown_firewall
    return unless offline?

    action 'Taking firewall down, internet is back'

    restore_iptables
  end
end
