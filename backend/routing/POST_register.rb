def POST_register(conn, client, method_token, target, host, port)
	response = Response.new
	all_headers = get_headers(client)
	body = client.read(all_headers['Content-Length'].to_i)
	begin
		hash = JSON.parse body.gsub('=>', ':')
		dto_hash = {}
		dto_hash["login"] = DtoParser.new("login", hash["login"], String, 1, -1)
		dto_hash["password"] = DtoParser.new("password", hash["password"], Password, -1, -1)
		dto_hash["email"] = DtoParser.new("email", hash["email"], Mail, -1, -1)
		hash = check_dto(hash, dto_hash)
		raise hash if hash.is_a?(String)
		raise "this email is already registered in database" if exist_by_value?('email', hash["email"], "users", conn)
		raise "this login is already registered in database" if exist_by_value?('login', hash["login"], "users", conn)
		hash["password"] = BCrypt::Password.create(hash["password"])
		hash["subscription_code"] = SecureRandom.uuid
		db_insert_request(conn, hash, "users")
		response.status_code  = "201 Created"
		response.message = JSON.generate(hash)
		send_mail(hash['email'], "Confirm your Camagru account", "#{host}:#{port}/confirmation/#{hash['subscription_code']}")
	rescue Exception => error
		response = forbidden_reponse(method_token, target, error.message)
	end
	return response
end