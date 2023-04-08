require_relative '../Response.rb'
require_relative '../server_util.rb'

def POST_delete_picture(conn, client, method_token, target)
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
		hash = check_dto(hash, dto_hash)
		raise hash if hash.is_a?(String)
		raise "this picture does not exist" if !exist_by_value?("id", hash['picture_id'], "pictures", conn)
		picture = find_by_value("id", hash['picture_id'], "pictures", conn)
		raise "you can't delete other's pictures" if picture['user_id'] != user['id']
		db_delete_request(conn, {:id => picture['id']} , "pictures")
		response.status_code  = "200 OK"
		response.message = JSON.generate({"success"=> "Picture #{picture['id']} has been deleeted successfully"})
	rescue Exception => error
		response = forbidden_reponse(method_token, target, error.message)
	end
	return response
end