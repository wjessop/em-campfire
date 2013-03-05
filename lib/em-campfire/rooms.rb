module EventMachine
  class Campfire
    module Rooms

      attr_accessor :room_cache, :joined_rooms

      def join(room_id, &blk)
        logger.info "Joining room #{room_id}"
        url = "https://#{subdomain}.campfirenow.com/room/#{room_id}/join.json"
        http = EventMachine::HttpRequest.new(url).post :head => {'Content-Type' => 'application/json', 'authorization' => [api_key, 'X']}
        http.errback { logger.error "Error joining room: #{room_id}" }
        http.callback {
          if http.response_header.status == 200
            logger.info "Joined room #{room_id} successfully"
            joined_rooms[room_id] = true
            yield(room_id) if block_given?
          else
            logger.error "Error joining room: #{room_id}"
          end
        }
      end

      def stream(room_id)
        json_parser = Yajl::Parser.new :symbolize_keys => true
        json_parser.on_parse_complete = method(:process_message)

        url = "https://streaming.campfirenow.com/room/#{room_id}/live.json"
        # Timeout per https://github.com/igrigorik/em-http-request/wiki/Redirects-and-Timeouts
        http = EventMachine::HttpRequest.new(url, :connect_timeout => 20, :inactivity_timeout => 0).get :head => {'authorization' => [api_key, 'X']}
        http.errback {
          logger.error "Couldn't stream room #{room_id} at url #{url}, error was #{http.error}"
          EM.next_tick {stream(room_id)}
        }
        http.callback {
          if http.response_header.status == 200
            logger.info "Disconnected from #{url}"
          else
            logger.error "Couldn't stream room with url #{url}, http response from API was #{http.response_header.status}"
          end
          EM.next_tick {stream(room_id)}
        }
        http.stream do |chunk|
          begin
            json_parser << chunk
          rescue Yajl::ParseError => e
            logger.error "Couldn't parse json data for room 123, data was #{chunk}, error was: #{e}"
            EM.next_tick {stream(room_id)}
          end
        end
      end

      #  curl -vvv -H 'Content-Type: application/json' -u API_KEY:X https://something.campfirenow.com/rooms.json
      def room_data_from_room_id(room_id, &block)
        url = "https://#{subdomain}.campfirenow.com/room/#{room_id}.json"

        etag_header = {}
        if cached_room_data = cache.get(room_cache_key(room_id))
          etag_header = {"ETag" => cached_room_data["etag"]}
        end

        http = EventMachine::HttpRequest.new(url).get :head => {'authorization' => [api_key, 'X'], 'Content-Type'=>'application/json'}.merge(etag_header)
        http.errback { logger.error "Couldn't connect to url #{url} to fetch room data" }
        http.callback {
          if http.response_header.status == 200
            room_data = Yajl::Parser.parse(http.response)['room']
            cache.set(room_cache_key(room_id), room_data.merge({'etag' => http.response_header.etag}))
            logger.debug "Fetched room data for #{room_id} (#{room_data['name']})"
            yield room_data if block_given?
          elsif http.response_header.status == 304
            logger.debug "HTTP response was 304, serving room data for room #{room_id} (#{cached_room_data['name']}) from cache"
            yield cached_room_data if block_given?
          else
            logger.error "Couldn't fetch room data with url #{url}, http response from API was #{http.response_header.status}"
          end
        }
      end

      def room_data_for_all_rooms
        url = "https://#{subdomain}.campfirenow.com/rooms.json"

        etag_header = {}
        if cached_room_list_data = cache.get(room_list_data_cache_key)
          etag_header = {"ETag" => cached_room_list_data["etag"]}
        end

        http = EventMachine::HttpRequest.new(url).get :head => {'Content-Type' => 'application/json', 'authorization' => [api_key, 'X']}.merge(etag_header)

        http.errback { logger.error "Error processing url #{url} to fetch room data: #{http.error}" }
        http.callback {
          if http.response_header.status == 200
            room_data = Yajl::Parser.parse(http.response)['rooms']
            cache.set(room_list_data_cache_key, {'data' => room_data, 'etag' => http.response_header.etag})
            logger.debug "Fetched room data for all rooms"
            yield room_data if block_given?
          elsif http.response_header.status == 304
            logger.debug "HTTP response was 304, serving room list data from cache"
            yield cached_room_list_data if block_given?
          else
            logger.error "Couldn't fetch room list with url #{url}, http response from API was #{http.response_header.status}"
          end
        }
      end

      private

      def joined_rooms
        @rooms ||= {}
      end

      def room_cache_key(room_id)
        "room-data-#{room_id}"
      end

      def room_list_data_cache_key
        "room-list-data"
      end
    end # Rooms
  end # Campfire
end # EventMachine
