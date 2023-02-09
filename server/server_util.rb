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
		Access-Control-Allow-Origin: *
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
