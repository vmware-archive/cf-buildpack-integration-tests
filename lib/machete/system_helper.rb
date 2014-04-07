module Machete
  module SystemHelper
    include Machete::Logger

    def run_cmd(cmd)
      logger.info "$ #{cmd}"
      result = `#{cmd}`
      logger.info result
      result
    end
  end
end