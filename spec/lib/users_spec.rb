require "spec_helper"

describe EventMachine::Campfire::Users do
  context "When fetching user data" do
    before :each do
      stub_rooms_data_request
      stub_join_room_request(123)
      EM.run_block { @adaptor = a(EM::Campfire) }
    end

    it "should get correct data for a user_id" do
      mock_logger
      stub_user_data_request(123)
      user_data = nil
      EM.run_block {
        @adaptor.fetch_user_data_for_user_id(123) do |user_data_hash|
          user_data = user_data_hash
        end
      }

      user_data.should eql(valid_user_cache_data[123])
      logger_output.should =~ %r{DEBUG.+Got the user data for 123}
    end

    it "should handle server errors" do
      mock_logger
      stub_user_data_request(123, 502)
      EM.run_block {
        @adaptor.fetch_user_data_for_user_id(123)
      }

      logger_output.should =~ %r{ERROR.+Couldn't fetch user data for user 123 with url .+, http response from API was 502}
    end

    it "should handle server timeouts" do
      mock_logger
      stub_timeout_user_data_request(123)
      EM.run_block {
        @adaptor.fetch_user_data_for_user_id(123)
      }

      logger_output.should =~ %r{ERROR.+Couldn't connect to .+ to fetch user data for user 123}
    end
  end
end
