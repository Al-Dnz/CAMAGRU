def	db_insert_request(conn, hash, table)
	columns_str = hash.keys().join(", ")
	values_str = []
	hash.keys().each { |key| values_str << "'#{hash[key]}'" }
	values_str = values_str.join(", ")
	conn.exec( "INSERT INTO \"#{table}\"(#{columns_str}) VALUES (#{values_str});" )
end

def check_dto(hash, dto_hash)
	new_hash = {}
	error = false
	errors_arr = []
	dto_hash.keys().each do |key|
		if !hash.key?(key)
			error = true
			errors_arr << "#{key} is missing"
			next
		end
		if hash[key].is_a?(dto_hash[key][:type])
			new_hash[key] = hash[key]
		else
			error = true
			errors_arr << "#{key} should be #{dto_hash[key][:type]}"
		end
		if dto_hash[key][:length] && hash[key].is_a?(String)
			min = dto_hash[key][:length][0]
			max = dto_hash[key][:length][1]
			if (min > -1 && hash[key].length < min)
				error = true
				errors_arr << "#{key} should be longer than #{min} char"
			end
			if (max > -1 && hash[key].length > max)
				error = true
				errors_arr << "#{key} should be shorter than #{max} char"
			end
		end
	end
	return error ? errors_arr.join(", ") : new_hash
end

def find_by_value(column, value, table, conn)	
	res = conn.exec( "SELECT * FROM \"#{table}\" WHERE #{column} = '#{value}' " )
	return res[0]
end

def exist_by_value?(column, value, table, conn)
	res =  conn.exec("SELECT EXISTS (SELECT 1 FROM \"#{table}\" WHERE #{column} = '#{value}')")
	return res[0]["exists"] == "t" ? true : false
end

# def exist_by_value?(to_find, conn)
# 	res =  conn.exec("SELECT EXISTS (SELECT 1 FROM \"#{to_find["table"]}\" WHERE #{to_find["column"]} = '#{to_find["value"]}')")
# 	return res[0]["exists"] == "t" ? true : false
# end

def update_by_value(conn, to_find, to_change)
	res =  conn.exec("UPDATE \"#{to_find["table"]}\" SET #{to_change["column"]}= '#{to_change["value"]}' WHERE #{to_find["column"]} = '#{to_find["value"]}'")
end

def get_table_datas(conn, table)
	data = []
	conn.exec( "SELECT * FROM \"#{table}\"" ) do |result|
		result.each do |row|
			hash = {}
			row.keys().each {|key| hash[key] = row.values_at(key).first}
			data << hash
		end
	end
	return JSON.generate(data)
end

def get_table_datas_with_users(conn, table)
	data = []
	conn.exec( "SELECT * FROM \"#{table}\"" ) do |result|
		result.each do |row|
			hash = {}
			row.keys().each {|key| hash[key] = row.values_at(key).first}
			data << hash
		end
	end
	data.each do |e|
		e["user"] = find_by_value("id", e["user_id"], "users", conn)["login"]	
	end
	return JSON.generate(data)
end


