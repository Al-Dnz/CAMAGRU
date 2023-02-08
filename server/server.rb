require 'socket'
require 'json'
require 'uri'
require 'pg'
require 'dotenv'

Dotenv.load("../.env")

port = 1337
server = TCPServer.new(port)
fd = IO.sysopen("/proc/1/fd/1", "w")
console = IO.new(fd,"w")
console.sync = true
console.puts "server launched on http://localhost:#{port}"
# puts "server launched on http://localhost:#{port}"

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

def	db_insert_request(conn, hash, table)
	columns_str = hash.keys().join(", ")
	values_str = []
	hash.keys().each { |key| values_str << "'#{hash[key]}'" }
	values_str = values_str.join(", ")
	conn.exec( "INSERT INTO \"#{table}\"(#{columns_str}) VALUES (#{values_str});" )
end

def check_dto(hash, dto_hash)
	new_hash = {}
	error = false
	errors_arr = []
	dto_hash.keys().each do |key|
		if hash[key].is_a?(dto_hash[key][:type])
			new_hash[key] = hash[key]
		else
			error = true
			errors_arr << "#{key} should be #{dto_hash[key][:type]}"
		end
		if dto_hash[key][:length] && hash[key].is_a?(String)
			min = dto_hash[key][:length][0]
			max = dto_hash[key][:length][1]
			if (min > -1 && hash[key].length < min)
				error = true
				errors_arr << "#{key} should be longer than #{min} char"
			end
			if (max > -1 && hash[key].length > max)
				error = true
				errors_arr << "#{key} should be shorter than #{max} char"
			end
		end
	end
	return error ? errors_arr.join(", ") : new_hash
end

puts ENV["POSTGRES_HOST"]
conn = PG::Connection.new(:host =>  ENV["POSTGRES_HOST"], :user => ENV["POSTGRES_USER"], :dbname => ENV["POSTGRES_DB"], :port => '5432', :password => ENV["POSTGRES_PASSWORD"])

loop do
	client = server.accept
	request_line = client.readline
	method_token, target, version_number = request_line.split
	
	response = Response.new

	# Switch on HTTP request
	case [method_token, target]
		when ["GET", "/data"]
			response.status_code = "200 OK"
			data = []
			conn.exec( "SELECT * FROM \"user\"" ) do |result|
				result.each do |row|
					hash = {}
					hash['first_name'] = row.values_at('first_name').first
					hash['last_name'] = row.values_at('last_name').first
					hash['email'] = row.values_at('email').first
					data << hash
				end
			end
			response.message = JSON.generate(data)
		when ["POST", "/data"]
			all_headers = get_headers(client)
			body = client.read(all_headers['Content-Length'].to_i)
			hash = JSON.parse body.gsub('=>', ':')

			# Refactor
			dto_hash = {}
			dto_hash["first_name"] = {type: String, length: [1, -1]}
			dto_hash["last_name"] = {type: String, length: [1, -1]}
			dto_hash["email"]= {type: String, length: [1, -1], contain: '@'}

			hash = check_dto(hash, dto_hash)
			if hash.is_a?(String)
				response.status_code = "403 FORBIDDEN"
				response.message = JSON.generate({error: hash})
				# response.content_type = "text/plain"
			else
				db_insert_request(conn, hash, "user")
				response.status_code  = "201 Created"
				response.message = JSON.generate(hash)
			end
		else
			response.status_code = "404 NOT_FOUND"
			response.message = "no route #{method_token} with the URL #{target}"
			response.content_type = "text/plain"
	end
	console.puts "[#{version_number}][#{method_token}] #{target} [#{response.status_code}]\n"

 	# Construct the HTTP Response
	http_response = construct_http_response(response, version_number, target)
	client.puts http_response
	client.close
end