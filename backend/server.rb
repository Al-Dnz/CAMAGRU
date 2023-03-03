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
host = "#{ENV["HOST"]}"

mode = ["DEV", "PROD"].include?(ARGV[0].upcase) ? ARGV[0].upcase : "PROD"

if mode == "DEV"
#DEV
	conn = PG::Connection.new(:host =>  'localhost' , :user => ENV["POSTGRES_USER"], :dbname => ENV["POSTGRES_DB"], :port => '5432', :password => ENV["POSTGRES_PASSWORD"])
	puts "server launched on http://#{host}:#{port}"
elsif mode == "PROD"
#PROD
	conn = PG::Connection.new(:host =>  ENV["POSTGRES_HOST"], :user => ENV["POSTGRES_USER"], :dbname => ENV["POSTGRES_DB"], :port => '5432', :password => ENV["POSTGRES_PASSWORD"])
	fd = IO.sysopen("/proc/1/fd/1", "w")
	console = IO.new(fd,"w")
	console.sync = true
	console.puts "server launched on http://#{host}:#{port}"
end

i = 1
loop do
	client = server.accept
	client_ip = client.peeraddr[2]
	request_line = client.readline
	method_token, target, version_number = request_line.split
	response = Response.new

	# Switch on HTTP request
	case [method_token, target.split('/')[1]]	
		when ["GET", "data"]
			# data = []
			# conn.exec( "SELECT * FROM \"pictures\"" ) do |result|
			# 	result.each do |row|
			# 		hash = {}
			# 		row.keys().each {|key| hash[key] = row.values_at(key).first}
			# 		data << hash
			# 	end
			# end
			response.status_code = "200 OK"
			# response.message = JSON.generate(data)
			response.message = get_table_datas(conn, "pictures")
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
					response = forbidden_reponse(method_token, target, hash)
				else
					if exist_by_value?('email', hash["email"], "users", conn)
						response = forbidden_reponse(method_token, target, "this email is already registered in database")
					elsif exist_by_value?('login', hash["login"], "users", conn)
						response = forbidden_reponse(method_token, target, "this login is already registered in database")
					else
						hash["subscription_code"] = SecureRandom.uuid
						db_insert_request(conn, hash, "users")
						response.status_code  = "201 Created"
						response.message = JSON.generate(hash)
					end
				end
			rescue JSON::ParserError
				response.status_code = "403 FORBIDDEN"
				response.message = JSON.generate({error: "JSON parsing error"})
			end
		when ["POST", "connect"]
			all_headers = get_headers(client)
			body = client.read(all_headers['Content-Length'].to_i)
			begin
				hash = JSON.parse body.gsub('=>', ':')
				dto_hash = {}
				dto_hash["login"] = {type: String, length: [1, -1]}
				dto_hash["password"] = {type: String, length: [1, -1]}
				hash = check_dto(hash, dto_hash)
				if hash.is_a?(String)
					response = forbidden_reponse(method_token, target, hash)
				else
					found = exist_by_value?("login",  hash["login"], "users", conn)
					if found
						user = find_by_value("login",  hash["login"], "users", conn)
						if user["password"] == hash["password"]  
							response.status_code = "200 OK"
							response.message = JSON.generate({:token => user["token"]})
						else
							response = forbidden_reponse(method_token, target, "wrong password")
						end
					else
						response = forbidden_reponse(method_token, target, "user not found")
					end
				end
			rescue JSON::ParserError
				response.status_code = "403 FORBIDDEN"
				response.message = JSON.generate({error: "JSON parsing error"})
			end
		when ["GET", "confirmation"]
			subscription_code = target.split('/')[2]
			if subscription_code == nil || !exist_by_value?('subscription_code', subscription_code, "users", conn) 
				response = not_found_response(method_token, target)
			else
				hash = find_by_value("subscription_code", subscription_code, "users", conn)
				id = hash["id"]
				to_find = {"table"=>"users", "column"=>"id", "value"=>"#{id}"}
				to_change = {"column"=>"validated", "value"=>"true"}
				update_by_value(conn, to_find, to_change)
				to_change = {"column"=>"subscription_code", "value"=>""}
				update_by_value(conn, to_find, to_change)
				token = "#{id}.#{SecureRandom.uuid.split('-').join()}"
				to_change = {"column"=>"token", "value"=>token}
				update_by_value(conn, to_find, to_change)
				hash = find_by_value("id", id, "users", conn)
				response.status_code  = "201 Created"
				response.message = JSON.generate(hash)
			end
		when ["POST", "pictures"]
			all_headers = get_headers(client)
			body = client.read(all_headers['Content-Length'].to_i)
			name = "blob_#{i}"
			File.open("./upload/#{name}", 'wb') { |f| f.write body }
			i+=1
			hash = {:path => "http://#{host}:#{port}/pictures/#{name}", :content=> "yolo", :user_id=> 1}
			db_insert_request(conn, hash, "pictures")
			response.status_code  = "201 Created"
			response.message = JSON.generate({"success"=> "OK"})
		when ["GET", "pictures"]
			pic_id = target.split('/')[2]
			if pic_id == nil
				response = not_found_response(method_token, target)
			else
				if !File.exist?("./upload/#{pic_id}")
					response = not_found_response(method_token, target)
				else
					File.open("./upload/#{pic_id}", 'r') { |f| response.message << f.read }
					response.status_code = "200 OK"
					response.content_type = "image/png"
				end
			end
		else
			response = not_found_response(method_token, target)
	end

	if (mode == "DEV")
		puts "[#{Time.now.utc}][#{client_ip}][#{version_number}][#{method_token}] #{target} [#{response.status_code}]\n"
	else
		console.puts "[#{Time.now.utc}][#{client_ip}][#{version_number}][#{method_token}] #{target} [#{response.status_code}]\n"
	end

 	# Construct the HTTP Response
	http_response = construct_http_response(response, version_number, target)
	client.puts http_response
	client.close
end