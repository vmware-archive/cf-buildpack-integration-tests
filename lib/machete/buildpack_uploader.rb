module Machete
  class BuildpackUploader
    attr_reader :language

    def initialize(language, offline = false)
      @language = language
      setup_language_buildpack
    end

    def buildpack_root
      return @buildpack_root if @buildpack_root

      @buildpack_root = ENV['BUILDPACK_ROOT'] || "../buildpacks"
      Machete::Logger.logger.info("BUILDPACK_ROOT not specified.\nDefaulting to '#{@buildpack_root}'") unless ENV['BUILDPACK_ROOT']
      @buildpack_root
    end

    private

    def setup_language_buildpack
      Machete::Logger.action("Installing buildpack for: #{language} in #{buildpack_mode} mode")

      result = Bundler.with_clean_env do
        if File.exists?("#{File.expand_path("cf-buildpack-#{language}", buildpack_root)}/bin/package")
          package_command = "./bin/package #{buildpack_mode}"
        else
          package_command = "bundle && #{online_string_var} bundle exec rake package"
        end

        Machete::Logger.logger.info %x(
          cd #{File.expand_path("cf-buildpack-#{language}", buildpack_root)} &&
          rm -f #{language}_buildpack.zip &&
          #{package_command} &&
          (cf create-buildpack #{language}-test-buildpack #{language}_buildpack.zip 1 --enable &&
          cf update-buildpack #{language}-test-buildpack -p #{language}_buildpack.zip --enable) &&
          rm #{language}_buildpack.zip
        )
      end

      if $? != 0
        Machete::Logger.logger.warn "Could not create the #{language} test buildpack: \n#{result}"
        exit(false)
      end

    end

    def buildpack_mode
      BuildpackMode.offline? ? "offline" : "online"
    end

    def online_string_var
      if BuildpackMode.offline?
        ""
      else
        "ONLINE=1"
      end
    end

  end
end
