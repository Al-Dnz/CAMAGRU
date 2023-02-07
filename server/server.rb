require 'socket'
require 'json'
require 'uri' 

port = 1337
server = TCPServer.new(port)
fd = IO.sysopen("/proc/1/fd/1", "w")
console = IO.new(fd,"w")
console.sync = true
console.puts "server launched on http://localhost:#{port}"

users = [
  { name: 'Polo', date: '01/01/2021' },
  { name: 'Jacky', date: '02/01/2021' },
  { name: 'Manu', date: '03/01/2021' },
]

class Response
	attr_accessor :status_code
	attr_accessor :content_type 
	attr_accessor :message

	def initialize(status_code: "", content_type: "application/json", message: "")
		@status_code = status_code
		@content_type = content_type
		@message = message
	end
end

def construct_http_response(response, version_number, target)
	http_response = <<~MSG
		#{version_number} #{response.status_code}
		Content-Type: #{response.content_type}; charset=#{response.message.encoding.name}
		Location: #{target}
		
		#{response.message}
	MSG
	return http_response 
end

def get_headers(client)
	all_headers = {}
	while true
		line = client.readline
		break if line == "\r\n"
		header_name, value = line.split(": ")
		all_headers[header_name] = value
	end
	return all_headers
end

loop do
	client = server.accept
	request_line = client.readline
	method_token, target, version_number = request_line.split
	
	response = Response.new
	
	# Switch on HTTP request
	console.print "[#{version_number}][#{method_token}] #{target}"
	case [method_token, target]
		when ["GET", "/data"]
			response.status_code = "200 OK"
			response.message = JSON.generate(users)
		when ["POST", "/data"]
			all_headers = get_headers(client)
			body = client.read(all_headers['Content-Length'].to_i)

			# new_user = URI.decode_www_form(body).to_h
			# new_user = new_user.transform_keys(&:to_sym)
			# console.puts "allheaders= #{body}"
			# users << new_user.transform_keys(&:to_sym)

			response.status_code  = "201 Created"
			response.message = body
		else
			response.status_code = "404 NOT_FOUND"
			response.message = "no route #{method_token} with the URL #{target}"
			response.content_type = "text/plain"
	end
	console.print " [#{response.status_code}]\n"

 	# Construct the HTTP Response
	http_response = construct_http_response(response, version_number, target)
	client.puts http_response
	client.close
end