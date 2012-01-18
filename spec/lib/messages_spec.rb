require "spec_helper"

describe EventMachine::Campfire::Messages do
    
  before :each do   
    stub_rooms_data_request
    stub_join_room_request(123)
    stub_stream_room_request(123)
    EM.run_block { @adaptor = a(EM::Campfire) }
  end

  it "should say a message" do
    mock_logger
    stub = stub_message_post_request
    
    EM.run_block {
      @adaptor.join 123
      @adaptor.say "Hi", 123
    }
    stub.should have_been_requested
    logger_output.should =~ /DEBUG.*Posted Textmessage "Hi" to room 123/
  end

  it "should paste a message" do
    mock_logger
    stub = stub_message_post_request
   
    EM.run_block {
      @adaptor.join 123
      @adaptor.paste "Hi", 123
    }
    stub.should have_been_requested
    logger_output.should =~ /DEBUG.*Posted PasteMessage "Hi" to room 123/
  end
    
  it "should play a sound" do
    mock_logger
    stub = stub_message_post_request
   
    EM.run_block {
      @adaptor.join 123
      @adaptor.play "nyan", 123
    }
    stub.should have_been_requested
    logger_output.should =~ /DEBUG.*Posted SoundMessage "nyan" to room 123/
  end
end
