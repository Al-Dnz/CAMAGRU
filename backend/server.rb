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
	puts "server launched on http://#{host}:#{port}"
elsif mode == "PROD"
	conn = PG::Connection.new(:host =>  ENV["POSTGRES_HOST"], :user => ENV["POSTGRES_USER"], :dbname => ENV["POSTGRES_DB"], :port => '5432', :password => ENV["POSTGRES_PASSWORD"])
	fd = IO.sysopen("/proc/1/fd/1", "w")
	console = IO.new(fd,"w")
	console.sync = true
	console.puts "server launched on http://#{host}:#{port}"
end

# response = Response.new
picture_index = 1
loop do
	client = server.accept
	client_ip = client.peeraddr[2]
	request_line = client.readline
	method_token, target, version_number = request_line.split
	
	# Switch on HTTP request
	case [method_token, target.split('/')[1]]	
		when ["GET", "data"]
			response = GET_data(conn)
		when ["POST", "register"]
			response = POST_register(conn, client, method_token, target, host, port)
		when ["POST", "connect"]
			response = POST_connect(conn, client, method_token, target)
		when ["GET", "confirmation"]
			response = GET_confirmation(conn, client, method_token, target, host)
		when ["POST", "pictures"]
			response = POST_pictures(conn, client, method_token, target, host, port, picture_index)
		when ["POST", "delete_picture"]
			response = POST_delete_picture(conn, client, method_token, target)
		when ["GET", "pictures"]
			response = GET_pictures(conn, client, method_token, target)
		when ["POST", "user"]
			response = POST_user(conn, client, method_token, target)
		when ["POST", "update_settings"]
			response = POST_update_settings(conn, client, method_token, target)
		when ["POST", "update_password"]
			response = POST_update_password(conn, client, method_token, target)
		when ["POST", "comment"]
			response = POST_comment(conn, client, method_token, target)
		when ["GET", "comment"]
			response = GET_comment(conn, client, method_token, target)
		when ["POST", "like"]
			response = POST_like(conn, client, method_token, target)
		when ["GET", "like"]
			response = GET_like(conn, client, method_token, target)
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