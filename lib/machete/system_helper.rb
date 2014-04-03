module SystemHelper
  def run_cmd(cmd)
    puts "$ #{cmd}" if ENV['PRINT_COMMANDS']
    `#{cmd}`
  end
end
