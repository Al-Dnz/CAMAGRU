class Response
	attr_accessor :status_code
	attr_accessor :content_type 
	attr_accessor :message

	def initialize(status_code: "", content_type: "application/json", message: "")
		@status_code = status_code
		@content_type = content_type
		@message = message
	end
end