require_relative './Response.rb'

def get_headers(client)
	all_headers = {}
	while true
		line = client.readline
		break if line == "\r\n"
		header_name, value = line.split(": ")
		all_headers[header_name] = value
	end
	return all_headers
end

def not_found_response(method_token, target)
	response = Response.new
	response.status_code = "404 NOT_FOUND"
	response.message = "no route #{method_token} with the URL #{target}"
	response.content_type = "text/plain"
	return response
end

def forbidden_reponse(method_token, target, error)
	response = Response.new
	response.status_code = "403 FORBIDDEN"
	response.message = JSON.generate({error: "#{error}"})
	return response
end

def check_token(token, conn)
	return nil if !token.is_a?(String)
	found = exist_by_value?("token",  token, "users", conn)
	if found
		user = find_by_value("token",  token, "users", conn)
		return user
	end
	return nil
end