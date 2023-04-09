def get_blob(body)
	first = body.enum_for(:scan, /(?=PNG)/).map do
		Regexp.last_match.offset(0).first
	end
	last = body.enum_for(:scan, /(?=IEND)/).map do
		Regexp.last_match.offset(0).first
	end
	first = first[0] - 1
	last = last[0] + 7
	body = body[first..last]
	return body
end

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