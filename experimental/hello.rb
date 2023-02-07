require 'socket'

port = 1337
server = TCPServer.new(port)
fd = IO.sysopen("/proc/1/fd/1", "w")
console = IO.new(fd,"w")
console.sync = true # send log message immediately, don't wait
console.puts "server launched on http://localhost:#{port}"

loop do
	client = server.accept
	request_line = client.readline
	method_token, target, version_number = request_line.split
	response_body = "Received a #{method_token} request to #{target} with #{version_number}"
	console.puts response_body
	client.puts response_body
	client.close
end