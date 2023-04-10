require 'socket'
require 'securerandom'
require 'fileutils'
require 'json'
require 'bcrypt'
require 'pg'
require 'dotenv'
require_relative './Response.rb'
require_relative './server_util.rb'
require_relative './request_util.rb'
require_relative './data_parsing.rb'
require_relative './mailer.rb'
require_relative './Response.rb'

Dir["./routing/*.rb"].each {|file| require file }
Dotenv.load("../.env")

port = 1337
server = TCPServer.new(port)
host = "#{ENV["HOST"]}"
mode = ["DEV", "PROD"].include?(ARGV[0].upcase) ? ARGV[0].upcase : "PROD"
if mode == "DEV"
	conn = PG::Connection.new(:host =>  'localhost' , :user => ENV["POSTGRES_USER"], :dbname => ENV["POSTGRES_DB"], :port => '5432', :password => ENV["POSTGRES_PASSWORD"])
	puts "[#{Time.now.utc}] server launched on http://#{host}:#{port}"
elsif mode == "PROD"
	conn = PG::Connection.new(:host =>  ENV["POSTGRES_HOST"], :user => ENV["POSTGRES_USER"], :dbname => ENV["POSTGRES_DB"], :port => '5432', :password => ENV["POSTGRES_PASSWORD"])
	fd = IO.sysopen("/proc/1/fd/1", "w")
	console = IO.new(fd,"w")
	console.sync = true
	console.puts "[#{Time.now.utc}] server launched on http://#{host}:#{port}"
end

picture_index = 1
loop do
	# Connect to client
	client = server.accept
	client_ip = client.peeraddr[2]
	begin
		# Get the request payload
		request_line = client.readline
		method_token, target, version_number = request_line.split
		
		# Switch response by HTTP request
		response = case [method_token, target.split('/')[1]]	
			when ["GET", "data"]
				GET_data(conn)
			when ["POST", "register"]
				POST_register(conn, client, method_token, target, host, port)
			when ["POST", "connect"]
				POST_connect(conn, client, method_token, target)
			when ["GET", "confirmation"]
				GET_confirmation(conn, client, method_token, target, host)
			when ["POST", "pictures"]
				POST_pictures(conn, client, method_token, target, host, port, picture_index)
			when ["POST", "delete_picture"]
				POST_delete_picture(conn, client, method_token, target)
			when ["GET", "pictures"]
				GET_pictures(conn, client, method_token, target)
			when ["POST", "user"]
				POST_user(conn, client, method_token, target)
			when ["POST", "update_settings"]
				POST_update_settings(conn, client, method_token, target)
			when ["POST", "update_password"]
				POST_update_password(conn, client, method_token, target)
			when ["POST", "comment"]
				POST_comment(conn, client, method_token, target)
			when ["GET", "comment"]
				GET_comment(conn, client, method_token, target)
			when ["POST", "like"]
				POST_like(conn, client, method_token, target)
			when ["GET", "like"]
				GET_like(conn, client, method_token, target)
			else
				not_found_response(method_token, target)
		end

		# Display in server the HTTP Request log
		if (mode == "DEV")
			puts "[#{Time.now.utc}][#{client_ip}][#{version_number}][#{method_token}] #{target} [#{response.status_code}]\n"
		else
			console.puts "[#{Time.now.utc}][#{client_ip}][#{version_number}][#{method_token}] #{target} [#{response.status_code}]\n"
		end

		# Send to client the HTTP Response
		http_response = response.to_http(version_number, target)
		client.puts http_response

	# Display errors in server and store it in error_logs file
	rescue => e
		File.open("./error_logs.txt", 'a') do |f| 
			f.write("[#{Time.now.utc}][#{client_ip}]\n")
			f.write("REQUEST => #{request_line}")
			f.write("ERROR   => #{e.message}\n")
			f.write( "-" * 100 + "\n")
		end
		error_msg = "⚠️  SERVER ERROR : [#{Time.now.utc}][#{client_ip}] => #{e.message}"
		puts error_msg if mode == "DEV"
		console.puts error_msg if mode == "PROD" 
	end
	client.close
end