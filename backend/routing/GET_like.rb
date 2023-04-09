def GET_like(conn, client, method_token, target)
	response = Response.new 
	response.status_code = "200 OK"
	response.message = get_table_datas_with_users(conn, "likes")
	return response
end