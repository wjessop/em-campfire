require "users_helper"

describe EventMachine::Campfire::Users do
  context "When fetching user data" do
    before :each do
      mock_logger
      stub_rooms_data_request
      stub_join_room_request(123)
      EM.run_block { @adaptor = a(EM::Campfire) }
    end

    it "should get correct data for a user_id" do
      stub_user_data_request(123)
      EM.run_block {
        @adaptor.fetch_user_data_for_user_id(123) do |user_data|
          user_data["name"].should eql(valid_user_cache_data[123]["name"])
        end
      }

      logger_output.should =~ %r{DEBUG.+Got the user data for 123}
    end

    it "should handle server errors" do
      stub_user_data_request(123, 502)
      EM.run_block {
        @adaptor.fetch_user_data_for_user_id(123)
      }

      logger_output.should =~ %r{ERROR.+Couldn't fetch user data for user 123 with url .+, http response from API was 502}
    end

    it "should handle server timeouts" do
      stub_timeout_user_data_request(123)
      EM.run_block {
        @adaptor.fetch_user_data_for_user_id(123)
      }

      logger_output.should =~ %r{ERROR.+Couldn't connect to .+ to fetch user data for user 123}
    end

    it "should cache user data" do
      stub_user_data_request(123)
      @adaptor.cache.expects(:set).with("user-data-123", valid_user_cache_data[123].merge({"etag" => etag_for_data(valid_user_cache_data[123])}))
      EM.run_block {
        @adaptor.fetch_user_data_for_user_id(123)
      }
    end

    it "should not update the user data cache when user data is fresh" do
      user_data = valid_user_cache_data[123]
      stub_user_data_request(123, 304)
      @adaptor.cache.expects(:get).with("user-data-123").returns(etag_for_data(user_data))
      @adaptor.cache.expects(:set).never

      EM.run_block {
        @adaptor.fetch_user_data_for_user_id(123)
      }
    end

    it "should update the user data cache when user data is stale" do
      user_data = valid_user_cache_data[123]
      user_data_with_etag = user_data.merge({"etag" => etag_for_data(user_data)})
      stub_user_data_request(123)
      @adaptor.cache.expects(:get).with("user-data-123").returns("no such etag")
      @adaptor.cache.expects(:set).with("user-data-123", user_data_with_etag)

      EM.run_block {
        @adaptor.fetch_user_data_for_user_id(123) {|data| data.should eql(user_data_with_etag)}
      }
    end
  end
end
