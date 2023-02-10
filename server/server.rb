require 'socket'
require 'json'
require 'uri'
require 'pg'
require 'dotenv'

$LOAD_PATH << '.'
require 'server_util.rb'
require 'request_util.rb'

Dotenv.load("../.env")

port = 1337
server = TCPServer.new(port)
fd = IO.sysopen("/proc/1/fd/1", "w")
console = IO.new(fd,"w")
console.sync = true
console.puts "server launched on http://localhost:#{port}"
# puts "server launched on http://localhost:#{port}"

conn = PG::Connection.new(:host =>  ENV["POSTGRES_HOST"], :user => ENV["POSTGRES_USER"], :dbname => ENV["POSTGRES_DB"], :port => '5432', :password => ENV["POSTGRES_PASSWORD"])

loop do
	client = server.accept
	request_line = client.readline
	method_token, target, version_number = request_line.split
	
	response = Response.new

	# Switch on HTTP request
	case [method_token, target]
		# console.puts target.split('/')
		when ["GET", "/data"]
			response.status_code = "200 OK"
			data = []
			conn.exec( "SELECT * FROM \"user\"" ) do |result|
				result.each do |row|
					hash = {}
					row.keys().each {|key| hash[key] = row.values_at(key).first}
					data << hash
				end
			end
			response.message = JSON.generate(data)
		when ["POST", "/data"]
			all_headers = get_headers(client)
			body = client.read(all_headers['Content-Length'].to_i)
			hash = JSON.parse body.gsub('=>', ':')

			# need Refactor
			dto_hash = {}
			dto_hash["first_name"] = {type: String, length: [1, -1]}
			dto_hash["last_name"] = {type: String, length: [1, -1]}
			dto_hash["email"] = {type: String, length: [1, -1], contain: '@'}

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
		when ["POST", "/pictures"]
		else
			response.status_code = "404 NOT_FOUND"
			response.message = "no route #{method_token} with the URL #{target}"
			response.content_type = "text/plain"
	end
	console.puts "[`#{Time.now.utc}`][#{version_number}][#{method_token}] #{target} [#{response.status_code}]\n"

 	# Construct the HTTP Response
	http_response = construct_http_response(response, version_number, target)
	client.puts http_response
	client.close
end