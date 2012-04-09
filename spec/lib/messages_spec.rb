require "spec_helper"

class MessageTester
  include EventMachine::Campfire::Messages
end

describe EventMachine::Campfire::Messages do
  before :each do
    @msg = MessageTester.new
  end
  
  context "posting messages" do
    it "should say" do
      @msg.expects(:send_message).with(123, "foo", "Textmessage")
      @msg.say("foo", 123)
    end
  
    it "should paste" do
      @msg.expects(:send_message).with(123, "foo", "PasteMessage")
      @msg.paste("foo", 123)
    end
  
    it "should play" do
      @msg.expects(:send_message).with(123, "foo", "SoundMessage")
      @msg.play("foo", 123)
    end
  end
  
  context "sending messages" do
    context "having failed to join a room" do
       before :each do   
         stub_rooms_data_request
         stub_join_room_request(123, 500)
         EM.run_block { @adaptor = a(EM::Campfire) }
       end
       
       it "should not try to post a message" do
         mock_logger
         stream = stub_stream_room_request(123)
         EM.run_block {
             @adaptor.say "Hi", 123
         }
         
         stream.should_not have_been_requested
         logger_output.should =~ %r{Couldn't post message "Hi" to room 123 as no rooms have been joined}
       end
     end
    
    context "having successfully joined a room" do
      before :each do   
        stub_rooms_data_request
        stub_join_room_request(123)
        stub_stream_room_request(123)
        EM.run_block { @adaptor = a(EM::Campfire) }
      end
    
      it "should say a message" do
        mock_logger
        stub = stub_message_post_request
      
        EM.run {
            @adaptor.join(123) { |id|
              @adaptor.say("Hi", id)
              EM.next_tick {
                EM.stop
              }
          }
        }
        stub.should have_been_requested
        logger_output.should =~ /DEBUG.*Posted Textmessage "Hi" to room 123/
      end
    
      it "should handle message posting failure" do
        mock_logger
        post_message_stub = stub_message_post_request(500)
        
        EM.run {
            @adaptor.join(123) { |id|
              @adaptor.say("Hi", id)
              EM.next_tick {
                EM.stop
              }
          }
        }
        
        post_message_stub.should have_been_requested
        logger_output.should =~ %r{ERROR.*Couldn't post message "Hi" to room 123 using url https://oxygen.campfirenow.com/room/123/speak.json, http response from the API was 500}
      end
    end
  end
end
