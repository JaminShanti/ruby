require 'slack-ruby-client'
require 'dotenv/load'

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

client = Slack::Web::Client.new

client.chat_postMessage(channel: '#general', text: 'Hello World', as_user: true)

puts "Message sent at #{Time.now.strftime("%c")}"
