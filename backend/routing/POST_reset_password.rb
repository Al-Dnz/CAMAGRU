def POST_reset_password(conn, client, method_token, target, host)
	response = Response.new
	all_headers = get_headers(client)
	body = client.read(all_headers['Content-Length'].to_i)
	begin
		hash = JSON.parse body.gsub('=>', ':')
		dto_hash = {}
		dto_hash["password"] = DtoParser.new("password", hash["password"], Password, 1, -1)
		dto_hash["reset_password_code"] = DtoParser.new("code", hash["reset_password_code"], String, 1, -1)
		hash = check_dto(hash, dto_hash)
		raise hash if hash.is_a?(String)
		reset_password_code = hash["reset_password_code"]
		raise "invalid reset password code" if !exist_by_value?('reset_password_code', reset_password_code, "users", conn)
		user = find_by_value("reset_password_code", reset_password_code, "users", conn)
		id = user['id']
		hash["password"] = BCrypt::Password.create(hash['password'])
		hash["reset_password_code"] = ""
		to_find = {"table"=>"users", "column"=>"id", "value"=>"#{id}"}
		hash.keys.each do |key|
			to_change = {"column"=>"#{key}", "value"=>"#{hash[key]}"}
			update_by_value(conn, to_find, to_change)
		end
		response.status_code  = "202 Accepted"
		response.message = JSON.generate(hash)
	rescue Exception => error
		response = forbidden_reponse(method_token, target, error.message)
	end

	return response
	









	
end


# if reset_password_code == nil || !exist_by_value?('reset_password_code', reset_password_code, "users", conn) 
# 	response = not_found_response(method_token, target)
# else
# 	user = find_by_value("reset_password_code", reset_password_code, "users", conn)
# 	token = user["token"]
# 	response.status_code = "200 OK"
# 	response.cookie = "token=#{token}; Path=/"
# 	response.message = JSON.generate({:token => token, :user => user['login']})
# end