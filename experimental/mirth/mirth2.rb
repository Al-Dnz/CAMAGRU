# mirth.rb
# HTTP Requests:
# Break down HTTP request from the client 
# and displays it 

require 'socket'

server = TCPServer.new(1337)

loop do
  client = server.accept

 request_line = client.readline

 puts "The HTTP request line looks like this:"
 puts request_line

  method_token, target, version_number = request_line.split 
  response_body =  "Received a #{method_token} request to #{target} with #{version_number}"

  client.puts response_body
  client.close
end
