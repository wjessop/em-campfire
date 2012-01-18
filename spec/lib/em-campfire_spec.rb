require "spec_helper"

describe EventMachine::Campfire do
  
  before :each do
    stub_rooms_data_request
  end
    
  describe "#initialize" do
    it "should work with valid params" do
      EM.run_block { a(EM::Campfire).should be_a(EM::Campfire) }
    end
    
    it "should warn if given an option it doesn't know" do
      mock_logger
      EM.run_block { a(EM::Campfire, :fred => "estaire").should be_a(EM::Campfire) }
      logger_output.should =~ /WARN.*em-campfire initialized with :fred => "estaire" but NO UNDERSTAND!/
    end
    
    it "should require essential parameters" do
      lambda { EM::Campfire.new }.should raise_error(ArgumentError, "You must pass an API key")
      lambda { EM::Campfire.new(:api_key => "foo") }.should raise_error(ArgumentError, "You must pass a subdomain")
    end
  end
  
  describe "#verbose" do
    it "should default to false" do
      EM.run_block { a(EM::Campfire).verbose.should be_false }
    end
    
    it "should be overridable at initialization" do
      EM.run_block { a(EM::Campfire, :verbose => true).verbose.should be_true }
    end
  end
  
  describe "#logger" do
    context "default logger" do
      before { EM.run_block { @adaptor = a EM::Campfire } }
      
      it { @adaptor.logger.should be_a(Logger) }
      it { @adaptor.logger.level.should be == Logger::INFO }
    end
    
    context "default logger in verbose mode" do
      before { EM.run_block { @adaptor = a EM::Campfire, :verbose => true } }
      
      it { @adaptor.logger.level.should be == Logger::DEBUG }
    end
    
    context "overriding default" do
      before do
        @custom_logger = Logger.new("/dev/null")
        EM.run_block { @adaptor = a EM::Campfire, :logger => @custom_logger }
      end
      
      it { @adaptor.logger.should be == @custom_logger }
    end

    
    
    # 
    # it "should handle HTTP errors fetching individual room data" do
    #   mock_logger
    #   bot = a Scamp
    # 
    #   EM.run_block {
    #     stub_request(:post, @message_post_url).
    #       with(:headers => {'Authorization'=>[valid_params[:api_key], 'X'], 'Content-Type' => 'application/json'}).
    #       to_return(:status => 502, :body => "", :headers => {'Content-Type'=>'text/html'})
    #     lambda {bot.send(:send_message, 123, "Hi", "Textmessage")}.should_not raise_error
    #   }
    #   logger_output.should =~ /ERROR.*Couldn't post message "Hi" to room 123 using url #{@message_post_url}, http response from the API was 502/
    # end
    #   
    # it "should handle network errors fetching individual room data" do
    #   mock_logger
    #   bot = a Scamp
    #     
    #   EM.run_block {
    #     stub_request(:post, @message_post_url).
    #       with(:headers => {'Authorization'=>[valid_params[:api_key], 'X'], 'Content-Type' => 'application/json'}).to_timeout
    #     lambda {bot.send(:send_message, 123, "Hi", "Textmessage")}.should_not raise_error
    #   }
    #   logger_output.should =~ /ERROR.*Couldn't connect to #{@message_post_url} to post message "Hi" to room 123/
    # end
    # 
    
    
    
    # context "user operations" do
       # it "should fetch user data" do
       #   adaptor = a EM::Campfire
       #   
       #   EM.run_block {
       #     stub_request(:get, "https://#{valid_params[:subdomain]}.campfirenow.com/users/123.json").
       #       with(:headers => {'Authorization'=>[valid_params[:api_key], 'X'], 'Content-Type'=>'application/json'}).
       #       to_return(:status => 200, :body => Yajl::Encoder.encode(:user => valid_user_cache_data[123]), :headers => {})
       #     adaptor.send(:username_for, 123)
       #     stub.should have_been_requested
       #   }
       # end
       
    #    it "should handle HTTP errors fetching user data" do
    #      mock_logger
    #      bot = a EM::Campfire
    #   
    #      url = "https://#{valid_params[:subdomain]}.campfirenow.com/users/123.json"
    #      EM.run_block {
    #        stub_request(:get, url).
    #          with(:headers => {'Authorization'=>[valid_params[:api_key], 'X'], 'Content-Type'=>'application/json'}).
    #          to_return(:status => 502, :body => "", :headers => {'Content-Type'=>'text/html'})
    #        lambda {bot.username_for(123)}.should_not raise_error
    #      }
    #      logger_output.should =~ /ERROR.*Couldn't fetch user data for user 123 with url #{url}, http response from API was 502/
    #    end
    #    
    #    it "should handle network errors fetching user data" do
    #      mock_logger
    #      bot = a EM::Campfire
    #      
    #      url = "https://#{valid_params[:subdomain]}.campfirenow.com/users/123.json"
    #      EM.run_block {
    #        stub_request(:get, url).
    #          with(:headers => {'Authorization'=>[valid_params[:api_key], 'X'], 'Content-Type'=>'application/json'}).to_timeout
    #        lambda {bot.username_for(123)}.should_not raise_error
    #      }
    #      logger_output.should =~ /ERROR.*Couldn't connect to #{url} to fetch user data for user 123/
    #    end
     end
     
    context "room operations" do
      before do
        @room_list_url = "https://#{valid_params[:subdomain]}.campfirenow.com/rooms.json"
        @me_list_url = "https://#{valid_params[:subdomain]}.campfirenow.com/users/me.json"
        @room_url = "https://#{valid_params[:subdomain]}.campfirenow.com/room/123.json"
        @stream_url = "https://streaming.campfirenow.com/room/123/live.json"
      end
      
      # it "should fetch a room list" do
      #   mock_logger
      #   bot = a EM::Campfire
      #   
      #   EM.run_block {
      #     stub_request(:get, @room_list_url).
      #       with(:headers => {'Authorization'=>[valid_params[:api_key], 'X']}).
      #       to_return(:status => 200, :body => Yajl::Encoder.encode(:rooms => valid_room_cache_data.values), :headers => {})
      #     bot.send(:populate_room_list)
      #     stub.should have_been_requested
      #   }
      #   logger_output.should =~ /DEBUG.*Fetched room list/
      # end
  
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
  # 
  #     it "should handle HTTP errors fetching the room list" do
  #       mock_logger
  #       bot = a EM::Campfire
  #     
  #       EM.run_block {
  #         # stub_request(:get, url).
  #         #   with(:headers => {'Authorization'=>[valid_params[:api_key], 'X'], 'Content-Type'=>'application/json'}).
  #         #   to_return(:status => 502, :body => "", :headers => {'Content-Type'=>'text/html'})
  #         stub_request(:get, @room_list_url).
  #           with(:headers => {'Authorization'=>[valid_params[:api_key], 'X']}).
  #           to_return(:status => 502, :body => "", :headers => {'Content-Type'=>'text/html'})
  #         lambda {bot.send(:populate_room_list)}.should_not raise_error
  #       }
  #       logger_output.should =~ /ERROR.*Couldn't fetch room list with url #{@room_list_url}, http response from API was 502/
  #     end
  #     
  #     it "should handle network errors fetching the room list" do
  #       mock_logger
  #       bot = a EM::Campfire
  #       EM.run_block {
  #         stub_request(:get, @room_list_url).
  #           with(:headers => {'Authorization'=>[valid_params[:api_key], 'X']}).to_timeout
  #         lambda {bot.send(:populate_room_list)}.should_not raise_error
  #       }
  #       logger_output.should =~ /ERROR.*Couldn't connect to url #{@room_list_url} to fetch room list/
  #     end
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
  #     
  #     it "should stream a room"
  #     it "should handle HTTP errors streaming a room"
  #     it "should handle network errors streaming a room"
  end
end

