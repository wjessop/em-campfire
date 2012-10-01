$:.unshift File.join(File.dirname(__FILE__), '../lib')

require 'em-campfire'

EM.run {
  connection = EM::Campfire.new(:subdomain => "foo", :api_key => "jhhekrlfjnksdjnliyherkjb", :verbose => true)

  # Join a room, you will need the room id
  connection.join(10101)

  # Stream a room, need to join it first
  connection.join(2345) {|id| connection.stream(id) }

  # Dump out any message we get
  connection.on_message do |msg|
    puts msg.inspect
  end

  # Pull data for a room
  connection.room_data_from_room_id(2345) {|data| puts data.inspect }

  # Pull data for all rooms
  connection.room_data_for_all_rooms {|data| puts data.inspect }

  # Fetch user data for a specific user
  connection.fetch_user_data_for_user_id(123) {|data| puts data.inspect }

  # Fetch data about the 'sef' user
  connection.fetch_user_data_for_self {|data| puts data.inspect }

  # Give lib a chance to connect
  EM::Timer.new(5) do
    # Say something on a specific channel
    connection.say "foofoofoo", 10101

    # Paste something
    connection.paste "foo\nfoo\nfoo", 10101

    # Play a sound
    connection.play "nyan", 10101
  end
}
