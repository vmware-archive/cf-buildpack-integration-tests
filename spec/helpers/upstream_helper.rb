module UpstreamHelper
  def setup_buildpack(buildpack_name = "ruby-integration-test")
    online_var = if buildpack_mode == :online
                   "ONLINE=1"
                 else
                   ""
                 end

    result = Bundler.with_clean_env do
      %x(
        cd #{buildpack_path} &&
        rm -f ruby_buildpack.zip &&
        bundle &&
        #{online_var} bundle exec rake package &&
        (cf create-buildpack #{buildpack_name} ruby_buildpack.zip 1 --enable ||
        cf update-buildpack #{buildpack_name} -p ruby_buildpack.zip --enable) &&
        rm ruby_buildpack.zip
      )
    end

    if $? != 0
      puts "Could not create the test buildpack: \n#{result}"
      exit(false)
    end
  end

  def buildpack_mode
    unless @buildpack_mode
      @buildpack_mode = (ENV['BUILDPACK_MODE'] || :online).downcase.to_sym
      puts "** WARNING ** BUILDPACK_MODE not specified, defaulting to '#{@buildpack_mode}'" unless ENV['BUILDPACK_MODE']
    end

    @buildpack_mode
  end

  def buildpack_path
    unless @buildpack_path
      @buildpack_path = ENV['BUILDPACK_PATH'] || "../heroku-buildpack-ruby-cf"
      puts "** BUILDPACK_PATH not specified, defaulting to '#{buildpack_path}'" unless ENV['BUILDPACK_PATH']
    end

    @buildpack_path
  end
end