require "users_helper"

class UsersTestContainer < ModuleHarness
  include EventMachine::Campfire::Users

  def cache; @cache ||= EventMachine::Campfire::Cache.new; end
end

describe EventMachine::Campfire::Users do
  describe "fetching user data" do
    before :each do
      mock_logger(UsersTestContainer)
      @adaptor = UsersTestContainer.new
    end

    it "should get correct data for a user_id" do
      stub_user_data_request(123)
      yielded_data = nil
      EM.run_block {
        @adaptor.fetch_user_data_for_user_id(123) do |user_data|
          yielded_data = user_data
        end
      }

      yielded_data["name"].should eql(valid_user_cache_data[123]["name"])

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

    describe "when the cache is fresh" do
      before :each do
        @user_data = valid_user_cache_data[456]
      end

      it "should not update the user cache data" do
        stub_user_data_request(123, 304)
        @adaptor.cache.expects(:get).with("user-data-123").returns(@user_data)
        @adaptor.cache.expects(:set).never

        EM.run_block {
          @adaptor.fetch_user_data_for_user_id(123)
        }
      end

      it "should serve cached data" do
        @adaptor.cache.expects(:get).with("user-data-456").returns(@user_data)
        stub_user_data_request(456, 304)
        yielded_data = nil

        EM.run_block {
          @adaptor.fetch_user_data_for_user_id(456) { |data| yielded_data = data }
        }

        logger_output.should =~ %r{DEBUG.+HTTP response was 304, serving user data for user 456 \(#{@user_data['name']}\) from cache}
        yielded_data.should eql(@user_data)
      end
    end

    it "should update the user data cache when user data is stale" do
      user_data = valid_user_cache_data[123]
      user_data_with_etag = user_data.merge({"etag" => etag_for_data(user_data)})
      stub_user_data_request(123)
      @adaptor.cache.expects(:get).with("user-data-123").returns(user_data)
      @adaptor.cache.expects(:set).with("user-data-123", user_data_with_etag)

      EM.run_block {
        @adaptor.fetch_user_data_for_user_id(123)
      }
    end
  end
end
