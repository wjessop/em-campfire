$:.unshift File.join(File.dirname(__FILE__), '../lib')

require 'em-campfire'

EM.run {
  connection = EM::Campfire.new(:subdomain => "foo", :api_key => "foo")
  connection.join 293788 # Robot Army
  connection.join 401839 # Monitoring
  
  connection.on_message do |msg|
    puts msg.inspect
  end
  
  # Give lib a chance to connect
  EM::Timer.new(10) do
    # Say something on a specific channel
    connection.say "foofoofoo", "Robot Army"
  end
}
