require 'socket'
require 'json'
require 'uri'
require 'open-uri'
require 'securerandom'
require 'pg'
require 'dotenv'
require 'base64'

require_relative './server_util.rb'
require_relative './request_util.rb'

Dotenv.load("../.env")

port = 1337
server = TCPServer.new(port)

mode = ["DEV", "PROD"][1]

if mode == "DEV"
#DEV
	conn = PG::Connection.new(:host =>  'localhost', :user => ENV["POSTGRES_USER"], :dbname => ENV["POSTGRES_DB"], :port => '5432', :password => ENV["POSTGRES_PASSWORD"])
	puts "server launched on http://#{ENV["HOST"]}:#{port}"
elsif mode == "PROD"
#PROD
	conn = PG::Connection.new(:host =>  ENV["POSTGRES_HOST"], :user => ENV["POSTGRES_USER"], :dbname => ENV["POSTGRES_DB"], :port => '5432', :password => ENV["POSTGRES_PASSWORD"])
	fd = IO.sysopen("/proc/1/fd/1", "w")
	console = IO.new(fd,"w")
	console.sync = true
	console.puts "server launched on http://#{ENV["HOST"]}:#{port}"
end

def not_found_response(method_token, target)
	response = Response.new
	response.status_code = "404 NOT_FOUND"
	response.message = "no route #{method_token} with the URL #{target}"
	response.content_type = "text/plain"
	return response
end

def forbidden_reponse(method_token, target, error)
	response = Response.new
	response.status_code = "403 FORBIDDEN"
	response.message = JSON.generate({error: "#{error}"})
	return response
end

i = 1
loop do
	client = server.accept
	request_line = client.readline
	method_token, target, version_number = request_line.split
	response = Response.new

	# Switch on HTTP request
	case [method_token, target.split('/')[1]]
		when ["GET", "data"]
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
		when ["POST", "register"]
			all_headers = get_headers(client)
			body = client.read(all_headers['Content-Length'].to_i)
			begin
				hash = JSON.parse body.gsub('=>', ':')
				
				dto_hash = {}
				dto_hash["login"] = {type: String, length: [1, -1]}
				dto_hash["password"] = {type: String, length: [1, -1]}
				dto_hash["email"] = {type: String, length: [1, -1], contain: '@'}
				hash = check_dto(hash, dto_hash)
				
				if hash.is_a?(String)
					response.status_code = "403 FORBIDDEN"
					response.message = JSON.generate({error: hash})
					# response.content_type = "text/plain"
				else
					if exist_by_value?('email', hash["email"], "user", conn)
						response.status_code = "403 FORBIDDEN"
						response.message = JSON.generate({error: "this email is already registered in database"})
					elsif exist_by_value?('login', hash["login"], "user", conn)
						response.status_code = "403 FORBIDDEN"
						response.message = JSON.generate({error: "this login is already registered in database"})
					else
						hash["subscription_code"] = SecureRandom.uuid
						db_insert_request(conn, hash, "user")
						response.status_code  = "201 Created"
						response.message = JSON.generate(hash)
					end
				end
			rescue JSON::ParserError
				response.status_code = "403 FORBIDDEN"
				response.message = JSON.generate({error: "JSON parsing error"})
			end
		when ["GET", "confirmation"]
			subscription_code = target.split('/')[2]
			if subscription_code == nil || !exist_by_value?('subscription_code', subscription_code, "user", conn) 
				response = not_found_response(method_token, target)
			else
				hash = find_by_value("subscription_code", subscription_code, "user", conn)
				id = hash["id"]
				to_find = {"table"=>"user", "column"=>"id", "value"=>"#{id}"}
				to_change = {"column"=>"validated", "value"=>"true"}
				update_by_value(conn, to_find, to_change)
				to_change = {"column"=>"subscription_code", "value"=>""}
				update_by_value(conn, to_find, to_change)
				hash = find_by_value("id", id, "user", conn)
				response.status_code  = "201 Created"
				response.message = JSON.generate(hash)
			end
		when ["POST", "pictures"]
			all_headers = get_headers(client)
			body = client.read(all_headers['Content-Length'].to_i)
			File.open("./upload/blob_#{i}", 'wb') { |f| f.write body }
			i+=1
			response.status_code  = "201 Created"
			response.message = JSON.generate({"success"=> "OK"})
		when ["GET", "pictures"]
			pic_id = target.split('/')[2]
			if !File.exist?("./upload/#{pic_id}")
				response = not_found_response(method_token, target)
			else
				File.open("./upload/#{pic_id}", 'r') { |f| response.message << f.read }
				response.status_code = "200 OK"
				response.content_type = "image/png"
			end
		else
			response = not_found_response(method_token, target)
	end

	if (mode == "DEV")
		puts "[`#{Time.now.utc}`][#{version_number}][#{method_token}] #{target} [#{response.status_code}]\n"
	else
		console.puts "[`#{Time.now.utc}`][#{version_number}][#{method_token}] #{target} [#{response.status_code}]\n"
	end

 	# Construct the HTTP Response
	http_response = construct_http_response(response, version_number, target)
	client.puts http_response
	client.close
end