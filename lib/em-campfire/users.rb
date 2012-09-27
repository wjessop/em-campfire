module EventMachine
  class Campfire
    module Users
      def fetch_user_data_for_user_id(user_id, &block)
        url = "https://#{subdomain}.campfirenow.com/users/#{user_id}.json"

        etag_header = {}
        if cached_user_data = cache.get(user_cache_key(user_id))
          etag_header = {"ETag" => cached_user_data["etag"]}
        end

        http = EventMachine::HttpRequest.new(url).get(:head => {'authorization' => [api_key, 'X'], "Content-Type" => "application/json"}.merge(etag_header))

        http.callback do
          if http.response_header.status == 200
            logger.debug "Got the user data for #{user_id}"
            user_data = Yajl::Parser.parse(http.response)['user']
            user_data['etag'] = http.response_header.etag
            cache.set(user_cache_key(user_id), user_data)
            yield user_data if block_given?
          else
            logger.error "Couldn't fetch user data for user #{user_id} with url #{url}, http response from API was #{http.response_header.status}"
          end
        end
        http.errback do
          logger.error "Couldn't connect to #{url} to fetch user data for user #{user_id}"
        end
      end

      private

      def user_cache_key(user_id)
        "user-data-#{user_id}"
      end
    end
  end
end
