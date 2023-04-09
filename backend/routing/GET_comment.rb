def GET_comment(conn, client, method_token, target)
	response = Response.new 
	response.status_code = "200 OK"
	response.message = get_table_datas_with_users(conn, "comments")
	return response
end