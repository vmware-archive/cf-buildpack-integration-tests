module SystemHelper
  def run_cmd(cmd)
    puts "$ #{cmd}"
    `#{cmd}`
  end
end
