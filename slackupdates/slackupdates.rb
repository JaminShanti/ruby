require 'slack-ruby-bot'




# source in secrets
File.readlines("#{ENV["HOME"]}/.password/twitterfile").each do |line|
  key, value  = line.split('=',2)
  ENV[key] = value.strip
end


client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['YOUR_CONSUMER_KEY']
  config.consumer_secret     = ENV['YOUR_CONSUMER_SECRET']
  config.access_token        = ENV['YOUR_ACCESS_TOKEN']
  config.access_token_secret = ENV['YOUR_ACCESS_SECRET']
end



client.update("@DigitalGlobe I am trying to get my w-2 from 2014.  Can someone call me back I have left 3 voicemails. Thank you.")

time = Time.now
puts "Tweeted at " + time.strftime("%c")
