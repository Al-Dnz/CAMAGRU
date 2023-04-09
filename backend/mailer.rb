require 'sendgrid-ruby'
include SendGrid

require 'dotenv'
Dotenv.load("../.env")

def send_mail(_to, _subject, _content)
	return 404 if !ENV['SENDGRID_EMAIL_SENDER'] || !ENV['SENDGRID_API_KEY']
	from = SendGrid::Email.new(email: ENV['SENDGRID_EMAIL_SENDER'])
	to = SendGrid::Email.new(email: _to)
	subject = "#{_subject}"
	content = SendGrid::Content.new(type: 'text/plain', value: "#{_content}")
	mail = SendGrid::Mail.new(from, subject, to, content)
	sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
	response = sg.client.mail._('send').post(request_body: mail.to_json)
	return response.status_code
	# puts response.body
	# puts response.headers
end