require 'sendgrid-ruby'
require 'dotenv'
Dotenv.load(".env")

sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
response = sg.client.user.credits.get()
puts response.status_code
JSON.parse(response.body).each{|key, value| puts "#{key} => #{value}"}