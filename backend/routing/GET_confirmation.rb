def html_response_code(host)
	return  "<!DOCTYPE html>
	<html>
		<head>
			<script>
				window.location.replace(\"http://#{host}:8000/index.html\");
			</script> 
		</head>
	</html>"
end

def GET_confirmation(conn, client, method_token, target, host)
	response = Response.new
	subscription_code = target.split('/')[2]
	if subscription_code == nil || !exist_by_value?('subscription_code', subscription_code, "users", conn) 
		response = not_found_response(method_token, target)
	else
		hash = find_by_value("subscription_code", subscription_code, "users", conn)
		id = hash["id"]
		to_find = {"table"=>"users", "column"=>"id", "value"=>"#{id}"}
		to_change = {"column"=>"validated", "value"=>"true"}
		update_by_value(conn, to_find, to_change)
		to_change = {"column"=>"subscription_code", "value"=>""}
		update_by_value(conn, to_find, to_change)
		token = "#{id}.#{SecureRandom.uuid.split('-').join()}"
		to_change = {"column"=>"token", "value"=>token}
		update_by_value(conn, to_find, to_change)
		hash = find_by_value("id", id, "users", conn)
		response.status_code  = "201 Created"
		response.content_type = "text/html; charset=utf-8"
		response.message = html_response_code(host)
		response.cookie = "token=#{token}; Path=/"
	end
	return response
end