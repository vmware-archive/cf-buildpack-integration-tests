module CloudFoundry
  def self.upstream_helper
    @upstream_helper ||= UpstreamHelper.new
  end

  def self.logger
    return @logger if @logger
    `mkdir -p log`
    @logger = Logger.new("log/integration.log")
  end
end

