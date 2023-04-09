# get user data usin POST method to check token 
def POST_user(conn, client, method_token, target)
	response = Response.new
	all_headers = get_headers(client)
	body = client.read(all_headers['Content-Length'].to_i)
	begin
		hash = JSON.parse body.gsub('=>', ':')
		token = hash['token']
		user = check_token(token, conn)
		raise "invalid token" if !user
		response.status_code = "200 OK"
		response.message = JSON.generate({:id => user["id"], :login => user["login"], :email => user["email"], :notified => user["notified"]})
	rescue Exception => error
		response = forbidden_reponse(method_token, target, error.message)
	end
	return response
end