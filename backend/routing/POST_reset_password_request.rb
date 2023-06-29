def	POST_reset_password_request(conn, client, method_token, target, host, client_port)
	response = Response.new
	all_headers = get_headers(client)
	body = client.read(all_headers['Content-Length'].to_i)
	begin
		hash = JSON.parse body.gsub('=>', ':')
		dto_hash = {}
		dto_hash["email"] = DtoParser.new("email", hash["email"], Mail, -1, -1)
		hash = check_dto(hash, dto_hash)
		raise hash if hash.is_a?(String)
		raise "this email is not registered in database" unless exist_by_value?('email', hash["email"], "users", conn)

		user = find_by_value("email",  hash['email'], "users", conn)
		reset_password_code = SecureRandom.uuid
		hash['reset_password_code'] = reset_password_code

		to_find = {"table"=>"users", "column"=>"id", "value"=>"#{user['id']}"}
		to_change = {"column"=>"reset_password_code", "value"=>reset_password_code}
		update_by_value(conn, to_find, to_change)

		response.status_code  = "201 Created"
		response.message = JSON.generate(hash)
		send_mail(user['email'], "Reset your Camagru password", "http://#{host}:#{client_port}/reset_password/form.html?code=#{hash['reset_password_code']}")
	rescue Exception => error
		response = forbidden_reponse(method_token, target, error.message)
	end
	return response
end