require "spec_helper"

# Old Scap specs

#     it "should invoke the post connection callback" do
#       mock_logger
#       bot = a EM::Campfire
# 
#       invoked_cb = false
# 
#       EM.run_block {
#         stub_request(:get, @room_list_url).
#         with(:headers => {
#                'Authorization'=>[valid_params[:api_key], 'X'],
#                'Content-Type' => 'application/json'
#              }).
#         to_return(:status => 200, :body => Yajl::Encoder.encode(:rooms => valid_room_cache_data.values), :headers => {})
# 
#         stub_request(:get, @room_list_url).
#         with(:headers => {
#                'Authorization'=>[valid_params[:api_key], 'X']
#              }).
#         to_return(:status => 200, :body => Yajl::Encoder.encode(:rooms => valid_room_cache_data.values), :headers => {})
# 
#         # Disable fetch_data_for, not important to this test.
#         EM::Campfire.any_instance.expects(:fetch_data_for).returns(nil)
# 
#         bot.send(:connect!, [valid_room_cache_data.keys.first]) do
#           invoked_cb = true
#         end
#       }
#       invoked_cb.should be_true
#     end


class ConnectionTester
  include EventMachine::Campfire::Connection
  
  # Nooooooooo!
  def is_me?(user_id)
    true
  end
  
  def receive_message(message)
    process_message(message)
  end
end

describe EventMachine::Campfire::Connection do
  context "#on_message" do
    it "should receive messages" do
      mock_logger(ConnectionTester)
      ConnectionTester.new.receive_message "foo"
      logger_output.should =~ /DEBUG.*Received message "foo"/
      logger_output.should =~ /DEBUG.*on_message callback does not exist/
    end
    
    it "should process on_message an block if present" do
      mock_logger(ConnectionTester)
      conn = ConnectionTester.new
      
      canary = mock
      canary.expects(:bang).with("foo")
      conn.on_message {|message| canary.bang(message) }
      conn.receive_message "foo"
      logger_output.should =~ /DEBUG.*on_message callback exists, calling it with "foo"/
    end
    
    it "should be able to ignore itself" do
      mock_logger(ConnectionTester)
      conn = ConnectionTester.new
      conn.ignore_self = true
      
      canary = mock
      canary.expects(:bang).never
      conn.on_message {|message| canary.bang }
      conn.receive_message({:user_id => 1})
    end
  end
end
