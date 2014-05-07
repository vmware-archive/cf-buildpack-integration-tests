require 'machete'

class UpstreamHelper

  attr_reader :existing_buildpacks

  def initialize
    @existing_buildpacks = {}
  end

  def setup_language_buildpack(language)
    return if has_buildpack?(language)

    Machete::BuildpackUploader.new(language, "#{buildpack_root}/cf-buildpack-#{language}")

    mark_buildpack_built(language)
  end

  def mark_buildpack_built(language)
    existing_buildpacks[language] = true
  end

  def has_buildpack?(language)
    existing_buildpacks[language]
  end

  def buildpack_root
    return @buildpack_root if @buildpack_root
    @buildpack_root = ENV['BUILDPACK_ROOT'] || "../buildpacks"
    Machete.logger.info("BUILDPACK_ROOT not specified.\nDefaulting to '#{@buildpack_root}'") unless ENV['BUILDPACK_ROOT']
    @buildpack_root
  end

end
