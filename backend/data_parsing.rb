class Validation
	attr_accessor :status
	attr_accessor :error 

	def initialize()
		@status = true
		@error = []
	end
end

class String
	def parser(name, str, min, max)
		validation = Validation.new
		if !str.is_a?(String)
			validation.status = false
			validation.error << "#{name} should be typed String"
			return validation
		end
		if (str.length < min && min > -1)
			validation.error << "#{name} should be greater than #{min} char"
		 end
		if (str.length > max && max > -1)
			validation.error << "#{name} should be shorter than #{max} char" 
		end
		validation.status = false if !validation.error.empty?
		return validation
	end
end

class Integer
	def parser(name, n, min, max)
		validation = Validation.new
		if !n.is_a?(Integer)
			validation.status = false
			validation.error << "#{name} should be typed Integer"
			return validation
		end
		validation.error << "#{name} should be greater than #{min}" if n < min && min > -1
		validation.error << "#{name} should be shorter than #{max}" if n > max && max > -1
		validation.status = false if !validation.error.empty?
		return validation
	end
end

class Boolean
	def parser(name, flag, min, max)
		validation = Validation.new
		if ![true, false].include? flag
			validation.status = false
			validation.error << "#{name} should be typed Boolean"
			return validation
		end
		validation.status = false if validation.error.empty?
		return validation
	end
end

class Mail
	def parser(name='email', mail, min, max)
		validation = Validation.new
		if !mail.is_a?(String)
			validation.status = false
			validation.error << "#{name} should be typed String"
			return validation
		end
		splitted = mail.split('@')
		validation.status = false if splitted.length != 2
		validation.status = false if (splitted.length == 2 && splitted[1].split('.').length == 1)
		validation.error << "wrong email format" if validation.status == false
	
		return validation
	end
end

class Password
	def parser(name='password', pass, min, max)
		validation = Validation.new
		if !pass.is_a?(String)
			validation.status = false
			validation.error << "#{name} should be typed String"
			return validation
		end
		validation.error << "#{name} size should be greater than 8 char" if pass.length < 8
		tmp_error = true
		pass.each_char {|c| tmp_error = false if c == c.downcase }
		validation.error << "#{name} should contain at least one downcased char" if tmp_error
		tmp_error = true
		pass.each_char {|c| tmp_error = false if c == c.upcase }
		validation.error << "#{name} should contain at least one upcased char" if tmp_error
		validation.error << "#{name} should contain at least one special char" if pass !~ /[!@#$%^&*()_+{}\[\]:;'"\/\\?><.,]/
		validation.status = false if !validation.error.empty?
		return validation
	end
end

class DtoParser
	attr_accessor :validation
	attr_accessor :error 
	attr_accessor :name 
	attr_accessor :value
	attr_accessor :type
	attr_accessor :min
	attr_accessor :max

	def initialize(_name, _value, _type, _min, _max)
		@name = _name
		@value = _value
		@type = _type
		@min = _min
		@max = _max

		validation = self.process()
		@validation = validation.status
		@error = validation.error
	end

	def process
		e = @type.new
		return e.parser(@name, @value, @min, @max)
	end

	def message()
		return @error.join(', ')
	end
end


def check_dto(hash, dto_hash)
	error = false
	errors_arr = []
	new_hash = {}
	dto_hash.keys().each do |key|
		if !hash.key?(key)
			error = true
			errors_arr << "#{key} is missing"
			next
		end
		dto_parser = dto_hash[key]
		new_hash[key] = hash[key]
		if dto_parser.validation == false
			error = true
			errors_arr << dto_parser.message() 
		end
	end
	return error ? errors_arr.join(", ") : new_hash
end



# str = ARGV[0]
# e = DtoParser.new(str, Password, 5, 10);
# e = DtoParser.new(str, String, 5, 10);
# str = str.to_i
# e = DtoParser.new(str, Numbers, 5, 10);
# str = true
# e = DtoParser.new('true', Booleans, 5, 10);
# puts e.error







