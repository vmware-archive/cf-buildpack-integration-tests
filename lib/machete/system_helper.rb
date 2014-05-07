module Machete
  module SystemHelper

    def run_cmd(cmd)
      Machete.logger.info "$ #{cmd}"
      result = `#{cmd}`
      Machete.logger.info result
      result
    end
  end
end