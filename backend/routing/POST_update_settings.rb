def POST_update_settings(conn, client, method_token, target)
	response = Response.new
	all_headers = get_headers(client)
	body = client.read(all_headers['Content-Length'].to_i)
	begin
		hash = JSON.parse body.gsub('=>', ':')
		token = hash['token'] || ""
		user = check_token(token, conn)
		raise "invalid token" if !user
		dto_hash = {}
		dto_hash["login"] = DtoParser.new("login", hash["login"], String, 1, -1)
		dto_hash["email"] = DtoParser.new("email", hash["email"], Mail, -1, -1)
		dto_hash["notified"] = DtoParser.new("notified", hash["notified"], Boolean, -1, -1)
		hash = check_dto(hash, dto_hash)
		raise hash if hash.is_a?(String)
		raise "this email is already registered in database" if exist_by_value?('email', hash["email"], "users", conn)  && hash["email"] != user["email"]
		raise "this login is already registered in database" if exist_by_value?('login', hash["login"], "users", conn) && hash["login"] != user["login"]
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
	return response	
end