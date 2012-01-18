require File.expand_path("../lib/em-campfire", File.dirname(__FILE__))

require 'mocha'
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
def mock_logger
  @logger_string = StringIO.new
  @fake_logger = Logger.new(@logger_string)
  EM::Campfire.any_instance.expects(:logger).at_least(1).returns(@fake_logger)
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

def valid_params
  {:api_key => "6124d98749365e3db2c9e5b27ca04db6", :subdomain => "oxygen"} 
end

def stub_join_room_request(room)
  url = "https://#{valid_params[:subdomain]}.campfirenow.com/room/#{room}/join.json"
  stub_request(:post, url).
    with(:headers => {'Authorization'=>[valid_params[:api_key], 'X'], 'Content-Type'=>'application/json'}).
    to_return(:status => 200, :body => "", :headers => {})
end

def stub_rooms_data_request
  stub_request(:get, "https://#{valid_params[:subdomain]}.campfirenow.com/rooms.json").
    with(:headers => {'Authorization'=>['6124d98749365e3db2c9e5b27ca04db6', 'X']}).
    to_return(:status => 200, :body => Yajl::Encoder.encode(:rooms => valid_room_cache_data.values), :headers => {})
end

def stub_message_post_request
  message_post_url = "https://#{valid_params[:subdomain]}.campfirenow.com/room/123/speak.json"
  stub_request(:post, message_post_url).
    with(:headers => {'Authorization'=>[valid_params[:api_key], 'X'], 'Content-Type' => 'application/json'}).
    to_return(:status => 201, :body => "", :headers => {})
end

def stub_stream_room_request(room)
  stub_request(:get, "https://streaming.campfirenow.com/room/#{room}/live.json").
    with(:headers => {'Authorization'=>[valid_params[:api_key], 'X']}).
    to_return(:status => 200, :body => "", :headers => {})
end
