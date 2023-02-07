require 'socket'
require 'json'
require 'uri' 

port = 1337
server = TCPServer.new(port)
# fd = IO.sysopen("/proc/1/fd/1", "w")
# console = IO.new(fd,"w")
# console.sync = true
# console.puts "server launched on http://localhost:#{port}"

users = [
  { name: 'Polo', date: '01/01/2021' },
  { name: 'Jacky', date: '02/01/2021' },
  { name: 'Manu', date: '03/01/2021' },
]

loop do
	client = server.accept

	request_line = client.readline
	method_token, target, version_number = request_line.split
	print "[#{version_number}][#{method_token}] #{target}"

	

	# Switch on HTTP request
	case [method_token, target]
		when ["GET", "/data"]
			response_status_code = "200 OK"
			content_type = "application/json"
			response_message = JSON.generate(users)
		when ["POST", "/data"]
			response_status_code = "201 Created"
			content_type = "application/json"
			response_message = ""
		
			all_headers = {}
			while true
			  line = client.readline
			  break if line == "\r\n"
			  header_name, value = line.split(": ")
			  all_headers[header_name] = value
			end
			body = client.read(all_headers['Content-Length'].to_i)
			new_user = URI.decode_www_form(body).to_h
		
			# users << new_user.transform_keys(&:to_sym)
			response_message = JSON.generate(new_user)
		else
			response_status_code = "404 NOT_FOUND"
			response_message = "no route #{method_token} with the URL #{target}"
			content_type = "text/plain"
	end
	print " [#{response_status_code}]\n"

  # Construct the HTTP Response
  http_response = <<~MSG
		#{version_number} #{response_status_code}
		Content-Type: #{content_type}; charset=#{response_message.encoding.name}
		Location: #{target}
		
		#{response_message}
	MSG
	client.puts http_response
	client.close
end