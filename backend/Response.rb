class Response
	attr_accessor :status_code
	attr_accessor :content_type 
	attr_accessor :message
	attr_accessor :cookie

	def initialize(status_code: "", content_type: "application/json", message: "")
		@status_code = status_code
		@content_type = content_type
		@message = message
		@cookie = nil
	end

	def to_http(version_number, target)
		http_response = <<~MSG
			#{version_number} #{self.status_code}
			Content-Type: #{self.content_type}; charset=#{self.message.encoding.name}
			Access-Control-Allow-Origin: *
			Location: #{target}
			Set-Cookie: #{self.cookie}
			
			#{self.message}
		MSG
		return http_response 
	end
end