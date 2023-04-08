require_relative '../Response.rb'
require_relative '../server_util.rb'
require 'bcrypt'

def POST_update_password(conn, client, method_token, target)
	response = Response.new
	all_headers = get_headers(client)
	body = client.read(all_headers['Content-Length'].to_i)
	begin
		hash = JSON.parse body.gsub('=>', ':')
		token = hash['token'] || ""
		user = check_token(token, conn)
		raise "invalid token" if !user
		dto_hash = {}
		dto_hash["password"] = DtoParser.new("password", hash["password"], Password, 1, -1)
		dto_hash["new_password"] = DtoParser.new("new_password", hash["new_password"], Password, -1, -1)
		hash = check_dto(hash, dto_hash)
		raise hash if hash.is_a?(String)
		raise "incorect password" if BCrypt::Password.new(user['password']) != hash['password']
		hash['password'] = BCrypt::Password.create(hash['new_password'])
		hash = hash.slice("password")
		id = user['id']
		to_find = {"table"=>"users", "column"=>"id", "value"=>"#{id}"}
		hash.keys.each do |key|
			to_change = {"column"=>"#{key}", "value"=>"#{hash[key]}"}
			update_by_value(conn, to_find, to_change)
		end
		response.status_code  = "201 Created"
		response.message = JSON.generate(hash)
	rescue Exception => error
		response = forbidden_reponse(method_token, target, error.message)
	end
	return response
end