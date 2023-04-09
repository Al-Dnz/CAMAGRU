def POST_like(conn, client, method_token, target)
	response = Response.new
	all_headers = get_headers(client)
	body = client.read(all_headers['Content-Length'].to_i)
	begin
		hash = JSON.parse body.gsub('=>', ':')
		token = hash['token']
		method = hash['method']
		user = check_token(token, conn)
		raise "method is missing for post like" if ["DELETE", "POST"].include?(hash['method']) == false
		raise "invalid token" if !user 
		dto_hash = {}
		dto_hash["picture_id"] = DtoParser.new("picture_id", hash["picture_id"], Integeri, 1, -1)
		hash = check_dto(hash, dto_hash)
		raise hash if hash.is_a?(String)
		raise "this picture does not exist in database" if !exist_by_value?('id', hash["picture_id"], "pictures", conn)	
		hash['user_id'] = user['id']
		if method == "POST"
			db_insert_request(conn, hash, "likes")
		elsif method == "DELETE"
			db_delete_request(conn, hash, "likes")
		end
		response.status_code = "200 OK"
		response.message = JSON.generate({:picture_id => hash["picture_id"]})
	rescue Exception => error
		response = forbidden_reponse(method_token, target, error.message)
	end
	return response
end