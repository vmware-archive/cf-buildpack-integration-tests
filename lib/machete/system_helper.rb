module SystemHelper
  def run_cmd(cmd)
    puts "$ #{cmd}" if ENV['PRINT_COMMANDS']
    result = `#{cmd}`
    puts result if ENV['PRINT_COMMANDS']
    result
  end
end
