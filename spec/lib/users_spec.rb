require "spec_helper"

describe EventMachine::Campfire::Users do
  #
  # Old Scamp specs
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