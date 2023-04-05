def	db_insert_request(conn, hash, table)
	columns_str = hash.keys().join(", ")
	values_str = []
	hash.keys().each { |key| values_str << "'#{hash[key]}'" }
	values_str = values_str.join(", ")
	res = conn.exec( "INSERT INTO \"#{table}\"(#{columns_str}) VALUES (#{values_str});" )
end

def	db_delete_request(conn, hash, table)
	condition = hash.map { |k, v| "#{k} = '#{v}'" }.join(' AND ')
	res = conn.exec("DELETE FROM #{table} WHERE #{condition}")
end

def find_by_value(column, value, table, conn)
	res = conn.exec( "SELECT * FROM \"#{table}\" WHERE #{column} = '#{value}' " )
	return res[0]
end

def exist_by_value?(column, value, table, conn)
	res =  conn.exec("SELECT EXISTS (SELECT 1 FROM \"#{table}\" WHERE #{column} = '#{value}')")
	return res[0]["exists"] == "t" ? true : false
end

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


