def GET_pictures(conn, client, method_token, target)
	response = Response.new
	pic_id = target.split('/')[2]
	if pic_id == nil
		response = not_found_response(method_token, target)
	else
		if !File.exist?("./upload/#{pic_id}")
			response = not_found_response(method_token, target)
		else
			file = File.open("./upload/#{pic_id}", 'r') { |f| response.message << f.read }
			file.close
			response.status_code = "200 OK"
			response.content_type = "image/png"
		end
	end
	return response	
end