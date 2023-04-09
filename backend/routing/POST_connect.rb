def POST_connect(conn, client, method_token, target)
	response = Response.new
	all_headers = get_headers(client)
	body = client.read(all_headers['Content-Length'].to_i)
	begin
		hash = JSON.parse body.gsub('=>', ':')
		dto_hash = {}
		dto_hash["login"] = DtoParser.new("login", hash["login"], String, 1, -1)
		dto_hash["password"] = DtoParser.new("password", hash["password"], Password, -1, -1)
		hash = check_dto(hash, dto_hash)
		raise hash if hash.is_a?(String)
		raise "user #{hash["login"]} not found" if !exist_by_value?("login",  hash["login"], "users", conn)
		user = find_by_value("login",  hash["login"], "users", conn)
		raise "invalid password "if BCrypt::Password.new(user["password"]) != hash["password"]  
		response.status_code = "200 OK"
		response.message = JSON.generate({:token => user["token"]})
	rescue Exception => error
		response = forbidden_reponse(method_token, target, error.message)
	end
	return response
	
end