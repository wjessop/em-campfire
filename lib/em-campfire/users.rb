module EventMachine
  class Campfire
    module Users
      def fetch_user_data_for_user_id(user_id, &block)
        url = "https://#{subdomain}.campfirenow.com/users/#{user_id}.json"
        http = EventMachine::HttpRequest.new(url).get(:head => {'authorization' => [api_key, 'X'], "Content-Type" => "application/json"})

        http.callback do
          if http.response_header.status == 200
            logger.debug "Got the user data for #{user_id}"
            yield Yajl::Parser.parse(http.response)['user']
          else
            logger.error "Couldn't fetch user data for user #{user_id} with url #{url}, http response from API was #{http.response_header.status}"
          end
        end
        http.errback do
          logger.error "Couldn't connect to #{url} to fetch user data for user #{user_id}"
        end
      end
    end
  end
end
