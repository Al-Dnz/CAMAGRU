require 'sendgrid-ruby'
include SendGrid

require 'dotenv'
Dotenv.load("../.env")

def send_mail(_to, _subject, _content)
	from = SendGrid::Email.new(email: ENV['SENDGRID_EMAIL_SENDER'])
	to = SendGrid::Email.new(email: _to)
	subject = "#{_subject}"
	content = SendGrid::Content.new(type: 'text/plain', value: "#{_content}")
	mail = SendGrid::Mail.new(from, subject, to, content)

	sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
	response = sg.client.mail._('send').post(request_body: mail.to_json)
	puts response.status_code
	# puts response.body
	# puts response.headers
end


