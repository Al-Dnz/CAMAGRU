require_relative '../Response.rb'
require_relative '../server_util.rb'

def POST_comment(conn, client, method_token, target)
	response = Response.new
	all_headers = get_headers(client)
	body = client.read(all_headers['Content-Length'].to_i)
	begin
		hash = JSON.parse body.gsub('=>', ':')
		token = hash['token']
		user = check_token(token, conn)
		raise "invalid token" if !user
		dto_hash = {}
		dto_hash["picture_id"] = DtoParser.new("picture_id", hash["picture_id"], Integeri, 1, -1)
		dto_hash["content"] = DtoParser.new("content", hash["content"], String, 1, -1)
		hash = check_dto(hash, dto_hash)
		raise hash if hash.is_a?(String)
		raise "this picture does not exist in database" if !exist_by_value?('id', hash["picture_id"], "pictures", conn)
		hash['user_id'] = user['id']
		db_insert_request(conn, hash, "comments")
		response.status_code = "200 OK"
		response.message = JSON.generate({:picture_id => hash["picture_id"], :content => hash["content"], :user => user["login"], :published_date => Time.now.strftime("%Y-%m-%d %H:%M:%S.%L") })
		picture = find_by_value("id", hash["picture_id"], "pictures", conn)
		pic_owner = find_by_value("id", picture['user_id'], "users", conn) if picture
		if pic_owner && pic_owner['notified'] == "t"
			content = "#{user['login']} has comented one of your pictures"
			send_mail(pic_owner['email'], "Notification from Camagru", content)
		end
	rescue Exception => error
		response = forbidden_reponse(method_token, target, error.message)
	end
	return response
end