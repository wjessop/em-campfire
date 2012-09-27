require 'simplecov'
require 'base64'

SimpleCov.start do
  add_filter "/spec/"
end

require File.expand_path("../lib/em-campfire", File.dirname(__FILE__))

require 'webmock/rspec'

RSpec.configure do |config|
  config.color_enabled = true
  config.mock_framework = :mocha
end

def a klass, params={}
  params ||= {}
  params = valid_params.merge(params) if klass == EM::Campfire
  klass.new(params)
end
  
# Urg
def mock_logger(klass = EM::Campfire)
  @logger_string = StringIO.new
  @fake_logger = Logger.new(@logger_string)
  klass.any_instance.expects(:logger).at_least(1).returns(@fake_logger)
end
  
# Bleurgh
def logger_output
  str = @logger_string.dup
  str.rewind
  str.read
end

def valid_user_cache_data
  {123 => {"name" => "foo"}, 456 => {"name" => "bar"}, 'me' => {"name" => "bot", "id" => 123}}
end

def valid_room_cache_data
  {
    123 => {
      "id" => 123,
      "name" => "foo",
      "users" => []
    },
    456 => {
      "id" => 456,
      "name" => "bar",
      "users" => []
    }
  }
end

def etag_for_data(data)
  "\"#{Base64.encode64(data.to_s).strip}\""
end

def valid_params
  {:api_key => "6124d98749365e3db2c9e5b27ca04db6", :subdomain => "oxygen"} 
end

def stub_user_data_request(user_id, response_code = 200)
  body = response_code == 200 ? Yajl::Encoder.encode(:user => valid_user_cache_data[user_id]) : ""
  stub_request(:get, "https://#{valid_params[:subdomain]}.campfirenow.com/users/#{user_id}.json").
    with(:headers => {'Authorization'=>['6124d98749365e3db2c9e5b27ca04db6', 'X']}).
    to_return(:status => response_code, :body => body, :headers => {:ETag => etag_for_data(valid_user_cache_data[user_id])})
end

def stub_timeout_user_data_request(user_id)
  stub_request(:get, "https://#{valid_params[:subdomain]}.campfirenow.com/users/#{user_id}.json").
    with(:headers => {'Authorization'=>['6124d98749365e3db2c9e5b27ca04db6', 'X']}).
    to_timeout
end

def stub_join_room_request(room, response_code = 200)
  url = "https://#{valid_params[:subdomain]}.campfirenow.com/room/#{room}/join.json"
  stub_request(:post, url).
    with(:headers => {'Authorization'=>[valid_params[:api_key], 'X'], 'Content-Type'=>'application/json'}).
    to_return(:status => response_code, :body => "", :headers => {})
end

def stub_rooms_data_request(response_code = 200)
  body = response_code == 200 ? Yajl::Encoder.encode(:rooms => valid_room_cache_data.values) : ""
  stub_request(:get, "https://#{valid_params[:subdomain]}.campfirenow.com/rooms.json").
    with(:headers => {'Authorization'=>['6124d98749365e3db2c9e5b27ca04db6', 'X']}).
    to_return(:status => response_code, :body => body, :headers => {:ETag => etag_for_data(valid_room_cache_data)})
end

def stub_message_post_request(response_code = 201)
  message_post_url = "https://#{valid_params[:subdomain]}.campfirenow.com/room/123/speak.json"
  stub_request(:post, message_post_url).
    with(:headers => {'Authorization'=>[valid_params[:api_key], 'X'], 'Content-Type' => 'application/json'}).
    to_return(:status => response_code, :body => "", :headers => {})
end

def stream_url_for_room(id)
  "https://streaming.campfirenow.com/room/#{id}/live.json"
end

def stub_stream_room_request(room, response_code = 200)
  stub_request(:get, stream_url_for_room(room)).
    with(:headers => {'Authorization'=>[valid_params[:api_key], 'X']}).
    to_return(:status => response_code, :body => "", :headers => {})
end
