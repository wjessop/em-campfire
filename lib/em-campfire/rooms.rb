module EventMachine
  class Campfire
    module Rooms
      
      attr_accessor :room_cache, :rooms
      
      def join(room, &blk)
        id = room_id(room)
        logger.info "Joining room #{id}"
        if id
          url = "https://#{subdomain}.campfirenow.com/room/#{id}/join.json"
          http = EventMachine::HttpRequest.new(url).post :head => {'Content-Type' => 'application/json', 'authorization' => [api_key, 'X']}
          http.errback { logger.error "Error joining room: #{id}" }
          http.callback {
            if http.response_header.status == 200
              logger.info "Joined room #{id} successfully"
              @rooms[id] = true
              stream(id)
              blk.call(id) if block_given?
            else
              logger.error "Error joining room: #{id}"
            end
          }
        end
      end
      
      private
      
      attr_accessor :populating_room_list
      
      def stream(room_id)
        json_parser = Yajl::Parser.new :symbolize_keys => true
        json_parser.on_parse_complete = method(:process_message)
        
        url = "https://streaming.campfirenow.com/room/#{room_id}/live.json"
        # Timeout per https://github.com/igrigorik/em-http-request/wiki/Redirects-and-Timeouts
        http = EventMachine::HttpRequest.new(url, :connect_timeout => 20, :inactivity_timeout => 0).get :head => {'authorization' => [api_key, 'X']}
        http.errback { logger.error "Couldn't stream room #{room_id} at url #{url}" }
        http.callback { logger.info "Disconnected from #{url}"; join(room_id) if rooms[room_id] }
        http.stream do |chunk|
          begin
            json_parser << chunk
          rescue Yajl::ParseError => e
            logger.error "Couldn't parse room data for room #{room_id} with url #{url}, http response data was #{chunk[0..50]}..."
          end
        end
      end
      
      
      def room_id(room_id_or_name)
        if room_id_or_name.is_a? Integer
          return room_id_or_name
        else
          return room_id_from_room_name(room_id_or_name)
        end
      end
      
      def room_id_from_room_name(room_name)
        logger.debug "Looking for room id for #{room_name}"
        
        if room_cache.has_key? room_name
          return room_cache[room_name]["id"]
        else
          logger.warn "Attempted to join #{room_name} but could not find an ID for it"
          return false
        end
      end
      
      #  curl -vvv -H 'Content-Type: application/json' -u API_KEY:X https://something.campfirenow.com/rooms.json
      def populate_room_list
        url = "https://#{subdomain}.campfirenow.com/rooms.json"
        http = EventMachine::HttpRequest.new(url).get :head => {'authorization' => [api_key, 'X']}
        http.errback { logger.error "Couldn't connect to url #{url} to fetch room list"; puts http.inspect }
        http.callback {
          if http.response_header.status == 200
            logger.debug "Fetched room list"
            new_rooms = {}
            Yajl::Parser.parse(http.response)['rooms'].each do |c|
              new_rooms[c["name"]] = c
            end
            @room_cache = new_rooms # replace existing room list
          else
            logger.error "Couldn't fetch room list with url #{url}, http response from API was #{http.response_header.status}"
          end
        }
      end      
    end # Rooms
  end # Campfire
end # EventMachine
