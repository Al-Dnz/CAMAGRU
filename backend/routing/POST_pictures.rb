require_relative '../Response.rb'
require_relative '../server_util.rb'

def POST_pictures(conn, client, method_token, target, host, port, i)
	response = Response.new
	all_headers = get_headers(client)
	body = client.read(all_headers['Content-Length'].to_i)
	begin
		token = body.lines[1].split[2][6..-3]
		user = check_token(token, conn)
		raise "invalid token" if !user	
		body = get_blob(body)
		FileUtils.mkdir_p 'upload'
		filename = "blob_#{i}"
		while File.exist?("./upload/#{filename}")
			i += 1
			filename = "blob_#{i}"
		end
		File.open("./upload/#{filename}", 'wb') { |f| f.write body }
		i+=1
		hash = {:path => "http://#{host}:#{port}/pictures/#{filename}", :user_id=> user["id"]}
		db_insert_request(conn, hash, "pictures")
		response.status_code  = "201 Created"
		response.message = JSON.generate({"success"=> "OK"})	
	rescue Exception => error
		response = forbidden_reponse(method_token, target, error.message)
	end
	return response
end