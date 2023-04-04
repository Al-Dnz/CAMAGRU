require 'socket'
require 'json'
require 'uri'
require 'open-uri'
require 'securerandom'
require 'pg'
require 'dotenv'
require 'base64'
require 'fileutils'
require_relative './server_util.rb'
require_relative './request_util.rb'
require_relative './data_parsing.rb'

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
			response.status_code = "200 OK"
			response.message = get_table_datas_with_users(conn, "pictures")
		when ["POST", "register"]
			all_headers = get_headers(client)
			body = client.read(all_headers['Content-Length'].to_i)
			begin
				hash = JSON.parse body.gsub('=>', ':')
				
				dto_hash = {}
				dto_hash["login"] = DtoParser.new("login", hash["login"], String, 1, -1)
				dto_hash["password"] = DtoParser.new("password", hash["password"], Password, -1, -1)
				dto_hash["email"] = DtoParser.new("email", hash["email"], Mail, -1, -1)
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
				# dto_hash["login"] = {type: String, length: [1, -1]}
				# dto_hash["password"] = {type: String, length: [1, -1]}

				dto_hash["login"] = DtoParser.new("login", hash["login"], String, 1, -1)
				dto_hash["password"] = DtoParser.new("password", hash["password"], Password, -1, -1)
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
			rescue => e
				response.status_code = "403 FORBIDDEN"
				response.message = JSON.generate({error: "#{e.message}"})
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
				response.content_type = "text/html; charset=utf-8"
				response.message = "<!DOCTYPE html>
									<html>
										<head>
											<script>
												window.location.replace(\"http://#{host}/index.html\");
											</script> 
										</head>
									</html>"
			end
		when ["POST", "pictures"]
			all_headers = get_headers(client)
			body = client.read(all_headers['Content-Length'].to_i)
			begin
				token = body.lines[1].split[2][6..-3]
				user = check_token(token, conn)
				if user	
					body = get_blob(body)
					FileUtils.mkdir_p 'upload'
					filename = "blob_#{i}"
					while File.exist?("upload/#{filename}")
						i += 1
						filename = "blob_#{i}"
					end
					File.open("./upload/#{filename}", 'wb') { |f| f.write body }
					i+=1
					hash = {:path => "http://#{host}:#{port}/pictures/#{filename}", :user_id=> user["id"]}
					db_insert_request(conn, hash, "pictures")
					response.status_code  = "201 Created"
					response.message = JSON.generate({"success"=> "OK"})
				else
					response = forbidden_reponse(method_token, target, "invalid token")
				end
			rescue
				response = forbidden_reponse(method_token, target, "invalid blob file")
			end
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
		when ["POST", "user"]
			# get user datas to update them
			all_headers = get_headers(client)
			body = client.read(all_headers['Content-Length'].to_i)
			hash = JSON.parse body.gsub('=>', ':')
			token = hash['token']
			user = check_token(token, conn)
			if user
				response.status_code = "200 OK"
				response.message = JSON.generate({:id => user["id"], :login => user["login"], :email => user["email"], :notified => user["notified"]})
			else
				response = forbidden_reponse(method_token, target, "invalid token")
			end
		when ["POST", "update_settings"]
			all_headers = get_headers(client)
			body = client.read(all_headers['Content-Length'].to_i)
			begin
				hash = JSON.parse body.gsub('=>', ':')
				token = hash['token'] || ""
				user = check_token(token, conn)
				if user
					dto_hash = {}
					dto_hash["login"] = DtoParser.new("login", hash["login"], String, 1, -1)
					dto_hash["email"] = DtoParser.new("email", hash["email"], Mail, -1, -1)
					dto_hash["notified"] = DtoParser.new("notified", hash["notified"], Boolean, -1, -1)
					hash = check_dto(hash, dto_hash)
					if hash.is_a?(String)
						response = forbidden_reponse(method_token, target, hash)
					else
						if exist_by_value?('email', hash["email"], "users", conn)  && hash["email"] != user["email"]
							response = forbidden_reponse(method_token, target, "this email is already registered in database")
						elsif exist_by_value?('login', hash["login"], "users", conn) && hash["login"] != user["login"]
							response = forbidden_reponse(method_token, target, "this login is already registered in database")
						else
							id = user['id']
							to_find = {"table"=>"users", "column"=>"id", "value"=>"#{id}"}
							
							hash.keys.each do |key|
								to_change = {"column"=>"#{key}", "value"=>"#{hash[key]}"}
								update_by_value(conn, to_find, to_change)
							end
							response.status_code  = "201 Created"
							response.message = JSON.generate(hash)
						end
					end
				else
					response = forbidden_reponse(method_token, target, "invalid token")
				end
			rescue JSON::ParserError
				response = forbidden_reponse(method_token, target, "invalid json payload")
			end
		when ["POST", "update_password"]
			all_headers = get_headers(client)
			body = client.read(all_headers['Content-Length'].to_i)
			begin
				hash = JSON.parse body.gsub('=>', ':')
				token = hash['token'] || ""
				user = check_token(token, conn)
				raise "invalid token" if !user
					dto_hash = {}
					dto_hash["password"] = DtoParser.new("password", hash["password"], Password, 1, -1)
					dto_hash["new_password"] = DtoParser.new("new_password", hash["new_password"], Password, -1, -1)
					hash = check_dto(hash, dto_hash)
					raise hash if hash.is_a?(String)
					raise "incorect password" if user['password'] != hash['password']
					hash['password'] = hash['new_password']
					hash = hash.slice("password")
					id = user['id']
					to_find = {"table"=>"users", "column"=>"id", "value"=>"#{id}"}
					hash.keys.each do |key|
						to_change = {"column"=>"#{key}", "value"=>"#{hash[key]}"}
						update_by_value(conn, to_find, to_change)
					end
					response.status_code  = "201 Created"
					response.message = JSON.generate(hash)
			rescue Exception => error
				response = forbidden_reponse(method_token, target, error.message)
			end
		when ["POST", "comment"]
			all_headers = get_headers(client)
			body = client.read(all_headers['Content-Length'].to_i)
			begin
				hash = JSON.parse body.gsub('=>', ':')
				token = hash['token']
				user = check_token(token, conn)
				if user
					dto_hash = {}
					dto_hash["picture_id"] = DtoParser.new("picture_id", hash["picture_id"], Integeri, 1, -1)
					dto_hash["content"] = DtoParser.new("content", hash["content"], String, 1, -1)
					hash = check_dto(hash, dto_hash)
					if !hash.is_a?(String)
						if !exist_by_value?('id', hash["picture_id"], "pictures", conn)
							response = forbidden_reponse(method_token, target, "this picture does not exist in database")
						else
							hash['user_id'] = user['id']
							db_insert_request(conn, hash, "comments")
							response.status_code = "200 OK"
							response.message = JSON.generate({:picture_id => hash["picture_id"], :content => hash["content"], :user => user["login"], :published_date => Time.now.strftime("%Y-%m-%d %H:%M:%S.%L") })
						end
					else
						response = forbidden_reponse(method_token, target, hash)
					end
				else
					response = forbidden_reponse(method_token, target, "invalid token")
				end
			rescue => error
				response = forbidden_reponse(method_token, target, error.class)
			end
		when ["GET", "comment"]
			response.status_code = "200 OK"
			response.message = get_table_datas_with_users(conn, "comments")
		when ["POST", "like"]
			all_headers = get_headers(client)
			body = client.read(all_headers['Content-Length'].to_i)
			begin
				hash = JSON.parse body.gsub('=>', ':')
				token = hash['token']
				method = hash['method']
				user = check_token(token, conn)
				raise "method is missing for post like" if ["DELETE", "POST"].include?(hash['method']) == false
				if user 
					dto_hash = {}
					dto_hash["picture_id"] = DtoParser.new("picture_id", hash["picture_id"], Integeri, 1, -1)
					hash = check_dto(hash, dto_hash)
					if !hash.is_a?(String)
						if !exist_by_value?('id', hash["picture_id"], "pictures", conn)
							response = forbidden_reponse(method_token, target, "this picture does not exist in database")
						else
							hash['user_id'] = user['id']
							if method == "POST"
								db_insert_request(conn, hash, "likes")
							elsif method == "DELETE"
								db_delete_request(conn, hash, "likes")
							end
							response.status_code = "200 OK"
							response.message = JSON.generate({:picture_id => hash["picture_id"]})
						end
					else
						raise hash
					end
				else
					raise "invalid token"
				end
			rescue Exception => error
				response = forbidden_reponse(method_token, target, error.message)
			end
		when ["GET", "like"]
			response.status_code = "200 OK"
			response.message = get_table_datas_with_users(conn, "likes")
		#### default switch ####	
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
	begin
		client.puts http_response
	rescue => e
		puts "⚠️ SERVER ERROR : #{e.message}" if mode == "DEV"
		console.puts "⚠️ SERVER ERROR : #{e.message}" if mode == "PROD" 
	end
	client.close
end