require "spec_helper"
require "rooms_helper"

def stub_message_post_request(response_code = 201)
  message_post_url = "https://#{valid_params[:subdomain]}.campfirenow.com/room/123/speak.json"
  stub_request(:post, message_post_url).
    with(:headers => {'Authorization'=>[valid_params[:api_key], 'X'], 'Content-Type' => 'application/json'}).
    to_return(:status => response_code, :body => "", :headers => {})
end