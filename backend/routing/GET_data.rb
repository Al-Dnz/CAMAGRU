def GET_data(conn)
	response = Response.new
	response.status_code = "200 OK"
	response.message = get_table_datas_with_users(conn, "pictures")
	return response	
end
