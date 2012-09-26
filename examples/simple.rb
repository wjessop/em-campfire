$:.unshift File.join(File.dirname(__FILE__), '../lib')

require 'em-campfire'

EM.run {
  connection = EM::Campfire.new(:subdomain => "SUBDOMAIN", :api_key => "YOUR_API_KEY", :verbose => true)
  connection.join 123
  connection.join 456
  
  connection.on_message do |msg|
    puts msg.inspect
  end
  
  # Give lib a chance to connect
  EM::Timer.new(10) do
    # Say something on a specific channel
    connection.say "foofoofoo", "Robot Army"
  end
}
