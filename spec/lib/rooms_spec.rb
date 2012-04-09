require "spec_helper"

# Old Scamp specs

#     
#     it "should fetch individual room data" do
#       mock_logger
#       bot = a EM::Campfire
#       
#       EM.run_block {
#         stub_request(:get, @room_url).
#           with(:headers => {'Authorization'=>[valid_params[:api_key], 'X']}).
#           to_return(:status => 200, :body => Yajl::Encoder.encode(:room => valid_room_cache_data[123]), :headers => {})
#         bot.room_name_for(123)
#       }
#       logger_output.should =~ /DEBUG.*Fetched room data for 123/
#     end
#     
#     it "should handle HTTP errors fetching individual room data" do
#       mock_logger
#       bot = a EM::Campfire
# 
#       EM.run_block {
#         stub_request(:get, @room_url).
#           with(:headers => {'Authorization'=>[valid_params[:api_key], 'X']}).
#           to_return(:status => 502, :body => "", :headers => {'Content-Type'=>'text/html'})
#         lambda {bot.room_name_for(123)}.should_not raise_error
#       }
#       logger_output.should =~ /ERROR.*Couldn't fetch room data for room 123 with url #{@room_url}, http response from API was 502/
#     end
#     
#     it "should handle network errors fetching individual room data" do
#       mock_logger
#       bot = a EM::Campfire
#       
#       EM.run_block {
#         stub_request(:get, @room_url).
#           with(:headers => {'Authorization'=>[valid_params[:api_key], 'X']}).to_timeout
#         lambda {bot.room_name_for(123)}.should_not raise_error
#       }
#       logger_output.should =~ /ERROR.*Couldn't connect to #{@room_url} to fetch room data for room 123/
#     end


describe EventMachine::Campfire::Rooms do
  context "#join" do
    before :each do
      @message_post_url = "https://#{valid_params[:subdomain]}.campfirenow.com/room/123/speak.json"
      stub_rooms_data_request
      EM.run_block { @adaptor = a(EM::Campfire) }
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
    
    it "should log rooms that are joined" do
      join_stub = stub_join_room_request(123)
      stream_stub = stub_stream_room_request(123)
      EM.run_block { @adaptor.join(123) }
      @adaptor.rooms[123].should eql(true)
    end
    
    it "should account for rooms that are left"
    
    it "should call a passed block on sucess" do
      mock_logger
      
      join_stub = stub_join_room_request(123)
      stream_stub = stub_stream_room_request(123)
      object = mock()
      object.expects(:ping).with(123)
          
      EM.run_block {
        @adaptor.join(123) {|room_id| object.ping(123) }
      }
    end
  end
  
  context "streaming" do
    before :each do
      @message_post_url = "https://#{valid_params[:subdomain]}.campfirenow.com/room/123/speak.json"
      stub_rooms_data_request
      EM.run_block { @adaptor = a(EM::Campfire) }
      stub_join_room_request(123)
    end
    
    it "should stream a room" do
      mock_logger
      stream_stub = stub_stream_room_request(123)
      
      EM.run_block { @adaptor.join(123) }
      stream_stub.should have_been_requested
    end
    
    it "should handle response errors streaming a room" do
      mock_logger
      stub_request(:get, stream_url_for_room(123)).
        with(:headers => {'Authorization'=>[valid_params[:api_key], 'X']}).
        to_return(:status => 201, :body => 'foobarbaz', :headers => {})
        
      lambda { 
        EM.run {
          @adaptor.join(123)
          # Join -> Stream takes two ticks  
          EM.next_tick { EM.next_tick { EM.stop } }
        }
      }.should_not raise_error
      
      logger_output.should =~ /ERROR.*Couldn't parse room data for room 123 with url #{stream_url_for_room(123)}, http response data was foobarbaz.../
    end
  end
  
  context "fetching metadata" do
    it "should fetch a room list" do
      mock_logger
      fetch_data_stub = stub_rooms_data_request
      EM.run_block { @adaptor = a(EM::Campfire) }
      fetch_data_stub.should have_been_requested
      logger_output.should =~ /DEBUG.*Fetched room list/
    end
    
    it "should handle failure fetching a room list" do
      mock_logger
      fetch_data_stub = stub_rooms_data_request(500)
      EM.run_block { @adaptor = a(EM::Campfire) }
      fetch_data_stub.should have_been_requested
      logger_output.should =~ %r{ERROR.*Couldn't fetch room list with url https://oxygen.campfirenow.com/rooms.json, http response from API was 500}
    end
    
  end
end
