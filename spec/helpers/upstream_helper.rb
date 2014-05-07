require 'machete'

class UpstreamHelper

  attr_reader :existing_buildpacks

  def initialize
    @existing_buildpacks = {}
  end

  def setup_language_buildpack(language)
    return if has_buildpack?(language)

    Machete::BuildpackUploader.new(language)

    mark_buildpack_built(language)
  end

  def mark_buildpack_built(language)
    existing_buildpacks[language] = true
  end

  def has_buildpack?(language)
    existing_buildpacks[language]
  end


end
