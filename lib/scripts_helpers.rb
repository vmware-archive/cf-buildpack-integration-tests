def warning_banner(*messages)
  warn('*' * 80)
  warn('**** WARNING')
  messages.each do |message|
    warn("**** #{message}")
  end
  warn('****')
end

def info(*messages)
  messages.each do |message|
    puts("INFO> #{message}")
  end
end