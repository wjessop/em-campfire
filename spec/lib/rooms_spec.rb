require "spec_helper"

describe EventMachine::Campfire::Rooms do
    
  before :each do
    @message_post_url = "https://#{valid_params[:subdomain]}.campfirenow.com/room/123/speak.json"
    stub_rooms_data_request
    EM.run_block { @adaptor = a(EM::Campfire) }
  end

  context "#join" do
    before :each do
      EM.run_block { @adaptor = a EM::Campfire }
    end
      
    it "should allow joining by id" do
      mock_logger
        
      join_stub = stub_join_room_request(123)
      stream_stub = stub_stream_room_request(123)
      EM.run_block { @adaptor.join(123) }
      logger_output.should =~ /INFO.*Joined room 123 successfully/
      join_stub.should have_been_requested
    end
      
    it "should allow joining by name" do
      join_stub = stub_join_room_request(123)
      stream_stub = stub_stream_room_request(123)
      EM.run_block { @adaptor.join("foo") }
      join_stub.should have_been_requested
    end
      
    it "should not be able to join an invalid room" do
      mock_logger
      stream_stub = stub_stream_room_request(9999999999999999)
      url = "https://#{valid_params[:subdomain]}.campfirenow.com/room/9999999999999999/join.json"
      join_stub = stub_request(:post, url).
        with(:headers => {'Authorization'=>[valid_params[:api_key], 'X'], 'Content-Type'=>'application/json'}).
        to_return(:status => 302, :body => "", :headers => {})
        
      EM.run_block { @adaptor.join(9999999999999999) }
      logger_output.should =~ /Error joining room: 9999999999999999/
      join_stub.should have_been_requested
      stream_stub.should_not have_been_requested
    end
  end
end
