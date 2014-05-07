require 'machete'

module CloudFoundry
  def self.upstream_helper
    @upstream_helper ||= UpstreamHelper.new
  end
end

