module EventMachine
  class Campfire
    module Messages
      def say(message, room_id_or_name)
        send_message(room_id_or_name, message, "TextMessage")
      end

      def paste(message, room_id_or_name)
        send_message(room_id_or_name, message, "PasteMessage")
      end

      def play(sound, room_id_or_name)
        send_message(room_id_or_name, sound, "SoundMessage")
      end
    
      private
    
      # curl -vvv -H 'Content-Type: application/json' -d '{"message":{"body":"Yeeeeeaaaaaahh", "type":"TextMessage"}}' -u API_KEY:X https://something.campfirenow.com/room/2345678/speak.json
      def send_message(room_id, payload, type)        
        unless joined_rooms[room_id]
          logger.error "Couldn't post message \"#{payload}\" to room #{room_id} as no rooms have been joined"
          return false
        end
        
        url = "https://#{subdomain}.campfirenow.com/room/#{room_id}/speak.json"
        http = EventMachine::HttpRequest.new(url).post :head => {'Content-Type' => 'application/json', 'authorization' => [api_key, 'X'], 'user-agent' => user_agent}, :body => Yajl::Encoder.encode({:message => {:body => payload.to_s, :type => type}})
        http.errback { logger.error "Couldn't connect to #{url} to post message \"#{payload}\" to room #{room_id}" }
        http.callback {
          if [200,201].include? http.response_header.status
            logger.debug "Posted #{type} \"#{payload}\" to room #{room_id}"
          else
            logger.error "Couldn't post message \"#{payload}\" to room #{room_id} using url #{url}, http response from the API was #{http.response_header.status}"
          end
        }
      end
    end
  end
end
