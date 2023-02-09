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