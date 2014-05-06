require 'webrick'
require 'socket'

server = WEBrick::HTTPServer.new :Port => ENV['PORT']

server.mount_proc '/' do |req, res|
  connection_string = ENV["DATABASE_URL"]

  domain = connection_string.split('@')[1].split(':')[0]
  port = connection_string.split(':')[3].split('/')[0]


  begin
    TCPSocket.new domain, port
  rescue  SocketError => e
    exception = e
  end

  if exception
    res.body = "Could not connect to Postgres: #{exception.message}"
  else
    res.body = "Connected to Postgres"
  end
end

trap 'INT' do server.shutdown end

server.start
