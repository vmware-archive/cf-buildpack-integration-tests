require 'scripts_helpers'

class UpstreamHelper

  attr_reader :existing_buildpacks

  def initialize
    @existing_buildpacks = {}
  end

  def setup_language_buildpack(language)
    return if has_buildpack?(language)

    online_var = if buildpack_mode == :online
                   "ONLINE=1"
                 else
                   ""
                 end

    result = Bundler.with_clean_env do
      puts %x(
        cd #{File.expand_path("cf-buildpack-#{language}", buildpack_root)} &&
        rm -f #{language}_buildpack.zip &&
        bundle &&
        #{online_var} bundle exec rake package &&
        (cf create-buildpack #{language}-test-buildpack #{language}_buildpack.zip 1 --enable &&
        cf update-buildpack #{language}-test-buildpack -p #{language}_buildpack.zip --enable) &&
        rm #{language}_buildpack.zip
      )
    end

    if $? != 0
      puts "Could not create the #{language} test buildpack: \n#{result}"
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

  def get_buildpack_mode
    mode = (ENV['BUILDPACK_MODE'] || :online).downcase.to_sym
    info('BUILDPACK_MODE not specified.', "Defaulting to '#{mode}'") unless ENV['BUILDPACK_MODE']
    mode
  end

  def buildpack_root
    @buildpack_root ||= get_buildpack_root
  end

  def get_buildpack_root
    path = ENV['BUILDPACK_ROOT'] || "../buildpacks"
    info('BUILDPACK_ROOT not specified.', "Defaulting to '#{path}'") unless ENV['BUILDPACK_ROOT']
    path
  end

  def check_test_dependencies
    services = `cf services`

    unless services =~ /^lilelephant/
      warning_banner(
          "Could not find 'lilelephant' service in current cf space",
          'Output was: ',
          services
      )
      exit(1)
    end
  end
end
