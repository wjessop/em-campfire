require "users_helper"

class UsersTestContainer < ModuleHarness
  include EventMachine::Campfire::Users

  def cache; @cache ||= EventMachine::Campfire::Cache.new; end
end

describe EventMachine::Campfire::Users do
  before :each do
    @adaptor = UsersTestContainer.new
  end

  describe "#is_me?" do
    it "should return true if the passed user_id belongs to me" do
      @adaptor.cache.stubs(:get).with('user-data-me').returns(valid_user_cache_data['me'])

      EM.run_block {
        @adaptor.is_me?(789).should eql(true)
      }
    end

    it "should return false if the passed user_id doesn't belong to me" do
      @adaptor.cache.stubs(:get).with('user-data-me').returns(valid_user_cache_data['me'])

      EM.run_block {
        @adaptor.is_me?(123).should eql(false)
      }
    end

    it "should use cached data if available" do
      @adaptor.cache.expects(:get).with('user-data-me').returns(valid_user_cache_data['me'])
      @adaptor.expects(:fetch_user_data_for_self).never
      EM.run_block { @adaptor.is_me?(789) }
    end

    it "should fetch data if no cached data is available" do
      mock_logger(UsersTestContainer)
      @adaptor.cache.expects(:get).with('user-data-me').returns(nil)
      @adaptor.expects(:fetch_user_data_for_self).once.yields(valid_user_cache_data['me'])

      EM.run_block {
        @adaptor.is_me?(789)
      }
      logger_output.should =~ /DEBUG.*No user data cache exists for me, fetching it now/
    end
  end

  describe "fetching user data" do
    before :each do
      mock_logger(UsersTestContainer)
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

    describe "about self" do
      it "should get correct data for self" do
        stub = stub_self_data_request
        yielded_data = nil
        EM.run_block {
          @adaptor.fetch_user_data_for_self {|data| yielded_data = data }
        }
        stub.should have_been_requested
        yielded_data.should eql(valid_user_cache_data['me'])
        # FIXME: Can't work out why these debug messages get dumped to the terminal when others don't
        logger_output.should =~ /DEBUG.+Got the user data for self/
      end

      it "should handle server errors" do
        stub_self_data_request(502)
        EM.run_block { @adaptor.fetch_user_data_for_self }

        logger_output.should =~ %r{ERROR.+Couldn't fetch user data for self with url .+, http response from API was 502}
      end

      it "should handle server timeouts" do
        stub_timeout_self_data_request
        EM.run_block { @adaptor.fetch_user_data_for_self }

        logger_output.should =~ %r{ERROR.+Couldn't connect to .+ to fetch user data for self}
      end

      describe "when the cache is fresh" do
        before :each do
          @user_data = valid_user_cache_data['me']
        end

        it "should not update the user cache data" do
          stub_self_data_request(304)
          @adaptor.cache.expects(:get).with("user-data-me").returns(@user_data)
          @adaptor.cache.expects(:set).never

          EM.run_block { @adaptor.fetch_user_data_for_self }
        end

        it "should serve cached data" do
          @adaptor.cache.expects(:get).with("user-data-me").returns(@user_data)
          stub_self_data_request(304)
          yielded_data = nil

          EM.run_block {
            @adaptor.fetch_user_data_for_self { |data| yielded_data = data }
          }

          logger_output.should =~ %r{DEBUG.+HTTP response was 304, serving user data for self from cache}
          yielded_data.should eql(@user_data)
        end
      end

      it "should update the user data cache when user data is stale" do
        user_data = valid_user_cache_data['me']
        user_data_with_etag = user_data.merge({"etag" => etag_for_data(user_data)})
        stub_self_data_request
        @adaptor.cache.expects(:get).with("user-data-me").returns(user_data)
        @adaptor.cache.expects(:set).with("user-data-me", user_data_with_etag)

        EM.run_block { @adaptor.fetch_user_data_for_self }
      end
    end
  end
end
