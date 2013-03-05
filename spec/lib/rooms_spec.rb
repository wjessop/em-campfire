require "rooms_helper"

class RoomsTestContainer < ModuleHarness
  include EventMachine::Campfire::Rooms

  def cache; @cache ||= EventMachine::Campfire::Cache.new; end
  def process_message; end
end

describe EventMachine::Campfire::Rooms do
  before :each do
    mock_logger(RoomsTestContainer)
    @adaptor = RoomsTestContainer.new
  end

  describe "#join" do
    it "should allow joining by id" do
      join_stub = stub_join_room_request(123)
      EM.run_block { @adaptor.join(123) }
      logger_output.should =~ /INFO.*Joined room 123 successfully/
      join_stub.should have_been_requested
    end

    it "should not be able to join an invalid room" do
      join_stub = stub_join_room_request(9999999, 302)
      EM.run_block { @adaptor.join(9999999) }
      logger_output.should =~ /Error joining room: 9999999/
    end

    it "should call a passed block on success" do
      join_stub = stub_join_room_request(123)
      object = mock()
      object.expects(:ping).with("foo")

      EM.run_block {
        @adaptor.join(123) {|room_id| object.ping("foo") }
      }
    end
  end

  describe "streaming" do
    it "should stream a room" do
      stream_stub = stub_stream_room_request(123, stream_message_json)
      @adaptor.expects(:process_message).with(stream_message)
      EM.run_block { @adaptor.stream(123)}
      stream_stub.should have_been_requested
      logger_output.should =~ /INFO.*Disconnected from #{stream_url_for_room(123)}/
    end

    it "should handle invalid json" do
      invalid_json = "{:one => two}\n"
      stream_stub = stub_stream_room_request(123, invalid_json)
      @adaptor.expects(:process_message).never
      EM.run_block { @adaptor.stream(123)}
      stream_stub.should have_been_requested
      logger_output.should =~ /Couldn't parse json data for room 123, data was #{invalid_json}, error was: parse error: invalid object key \(must be a string\)/
    end

    it "should handle server timeouts" do
      request = stub_timeout_stream_room_request(123)

      EM.run_block {@adaptor.stream(123)}
      logger_output.should =~ /ERROR.*Couldn't stream room 123 at url #{stream_url_for_room(123)}, error was WebMock timeout error/
    end

    it "should re-connect to a streaming URL when timed out" do
      request = stub_timeout_stream_room_request(123)

      EM.run_block {@adaptor.stream(123)}
      request.should have_been_requested.twice
      logger_output.should =~ /ERROR.*Couldn't stream room 123 at url #{stream_url_for_room(123)}, error was WebMock timeout error/
    end

    it "should handle server errors streaming data" do
      request = stub_stream_room_request(123, "", 500)

      EM.run_block {@adaptor.stream(123)}
      request.should have_been_requested
      logger_output.should =~ /ERROR.*Couldn't stream room with url #{stream_url_for_room(123)}, http response from API was 500/
    end

    it "should re-connect to a streaming URL when disconnected" do
      stream_stub = stub_stream_room_request(123, "")
      EM.run {
        @adaptor.stream(123)
        # Re-connecting takes two ticks
        EM.next_tick { EM.next_tick {EM.stop} }
      }
      logger_output.should =~ /INFO.*Disconnected from #{stream_url_for_room(123)}/
      stream_stub.should have_been_requested.twice
    end
  end

  describe "fetching metadata" do
    describe "for individual rooms" do
      it "should fetch room data" do
        request = stub_room_data_request(123)
        yielded_data = nil

        EM.run_block {
          @adaptor.room_data_from_room_id(123) {|data| yielded_data = data}
        }

        yielded_data.should eql(valid_room_cache_data[123])
        request.should have_been_requested
        logger_output.should =~ /DEBUG.*Fetched room data for 123 \(#{valid_room_cache_data[123]['name']}\)/
      end

      it "should handle server errors fetching data" do
        request = stub_room_data_request(123, 500)

        EM.run_block {@adaptor.room_data_from_room_id(123)}
        request.should have_been_requested
        logger_output.should =~ /ERROR.*Couldn't fetch room data with url #{room_data_url(123)}, http response from API was 500/
      end


      it "should handle server timeouts" do
        request = stub_timeout_room_data_request(123)

        EM.run_block {@adaptor.room_data_from_room_id(123)}
        request.should have_been_requested
        logger_output.should =~ /ERROR.*Couldn't connect to url #{room_data_url(123)} to fetch room data/
      end

      it "should not update the room data cache when room data is fresh" do
        request = stub_room_data_request(123, 304)
        room_data = valid_room_cache_data[123]
        room_data_with_etag = room_data.merge({'etag' => etag_for_data(room_data)})
        @adaptor.cache.expects(:get).with("room-data-123").returns(room_data_with_etag)
        @adaptor.cache.expects(:set).never

        EM.run_block { @adaptor.room_data_from_room_id(123) }
        logger_output.should =~ /DEBUG.*HTTP response was 304, serving room data for room 123 \(#{room_data['name']}\) from cache/
      end

      it "should update the room data cache when room data is stale" do
        request = stub_room_data_request(123)
        room_data = valid_room_cache_data[123]
        room_data_with_etag = room_data.merge({'etag' => etag_for_data(valid_room_cache_data[123])})
        @adaptor.cache.expects(:get).with("room-data-123").returns(valid_room_cache_data[123].merge({'etag' => etag_for_data("no such etag")}))
        @adaptor.cache.expects(:set).with("room-data-123", valid_room_cache_data[123].merge({'etag' => etag_for_data(room_data)}))

        EM.run_block { @adaptor.room_data_from_room_id(123) }
      end
    end

    describe "for all rooms" do
      before :each do
        @cache_response = {'etag' => etag_for_room_list_data, 'data' => room_list_data_api_response['rooms']}
        @adaptor.cache.expects(:get).with("room-list-data").returns(@cache_response)
      end

      it "should fetch a room list" do
        request = stub_room_list_data_request
        rooms_data = room_list_data_api_response
        rooms_data_with_etag = rooms_data.merge({'etag' => etag_for_data(rooms_data)})

        yielded_data = nil

        EM.run_block {
          @adaptor.room_data_for_all_rooms {|data| yielded_data = data}
        }

        yielded_data.should eql(room_list_data_api_response['rooms'])

        request.should have_been_requested
        logger_output.should =~ /DEBUG.*Fetched room data for all rooms/
      end

      it "should handle server errors fetching data" do
        request = stub_room_list_data_request(500)

        EM.run_block {@adaptor.room_data_for_all_rooms}

        request.should have_been_requested
        logger_output.should =~ /ERROR.*Couldn't fetch room list with url #{rooms_data_url}, http response from API was 500/
      end

      it "should handle server timeouts" do
        request = stub_timeout_room_list_data_request

        EM.run_block {@adaptor.room_data_for_all_rooms}
        request.should have_been_requested

        logger_output.should =~ /ERROR.*Error processing url #{rooms_data_url} to fetch room data: WebMock timeout error/
      end

      describe "when the cached data is fresh" do
        before :each do
          stub_room_list_data_request(304)
          rooms_data = room_list_data_api_response
          @rooms_data_with_etag = rooms_data.merge({'etag' => etag_for_room_list_data})
        end

        it "should not update the cached room list" do
          @adaptor.cache.expects(:set).never

          EM.run_block { @adaptor.room_data_for_all_rooms }
        end

        it "should serve cached data" do
          yielded_data = nil

          EM.run_block {
            @adaptor.room_data_for_all_rooms { |data| yielded_data = data }
          }

          logger_output.should =~ /DEBUG.*HTTP response was 304, serving room list data from cache/
          yielded_data.should eql(@cache_response)
        end
      end

      it "should update the room list data cache when room data is stale" do
        stub_room_list_data_request
        @adaptor.cache.expects(:set).with("room-list-data", {'data' => room_list_data_api_response['rooms'], 'etag' => 'new etag'})
        EM.run_block { @adaptor.room_data_for_all_rooms }
      end
    end
  end
end
