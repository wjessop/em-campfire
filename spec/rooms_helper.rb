require "spec_helper"

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

# Joining a room

def stub_join_room_request(room, response_code = 200)
  url = "https://#{valid_params[:subdomain]}.campfirenow.com/room/#{room}/join.json"
  stub_request(:post, url).
    with(:headers => {'Authorization'=>[valid_params[:api_key], 'X'], 'Content-Type'=>'application/json', 'User-Agent' => valid_params[:user_agent]}).
    to_return(:status => response_code, :body => "", :headers => {})
end

# Streaming a room

def stream_url_for_room(id)
  "https://streaming.campfirenow.com/room/#{id}/live.json"
end

def stub_stream_room_request(room_id, body, response_code = 200)
  stub_request(:get, stream_url_for_room(room_id)).
    with(:headers => {'Authorization'=>[valid_params[:api_key], 'X'], 'User-Agent' => valid_params[:user_agent]}).
    to_return(:status => response_code, :body => body, :headers => {})
end

def stub_timeout_stream_room_request(room_id)
  stub_request(:get, stream_url_for_room(room_id)).
    with(:headers => {'Authorization'=>[valid_params[:api_key], 'X'], 'User-Agent' => valid_params[:user_agent]}).
    to_timeout
end

def stream_message(body = "This is the body of the message")
  {:room_id=>19505, :created_at=>"2012/10/01 14:24:49 +0000", :body=>body, :starred=>false, :id=>685107688, :user_id=>599452, :type=>"TextMessage"}
end

def stream_message_json(body = "This is the body of the message")
  Yajl::Encoder.encode stream_message(body)
end

# Individual room data requests

def room_data_url(room_id)
  "https://#{valid_params[:subdomain]}.campfirenow.com/room/#{room_id}.json"
end

def stub_room_data_request(room_id, response_code = 200)
  body = response_code == 200 ? Yajl::Encoder.encode(:room => valid_room_cache_data[room_id]) : ""
  stub_request(:get, room_data_url(room_id)).
    with(:headers => {'Authorization'=>['6124d98749365e3db2c9e5b27ca04db6', 'X'], 'Content-Type'=>'application/json', 'User-Agent' => valid_params[:user_agent]}).
    to_return(:status => response_code, :body => body, :headers => {:ETag => etag_for_data(valid_room_cache_data[room_id])})
end

def stub_timeout_room_data_request(room_id)
  stub_request(:get, room_data_url(room_id)).
    with(:headers => {'Authorization'=>['6124d98749365e3db2c9e5b27ca04db6', 'X'], 'User-Agent' => valid_params[:user_agent]}).
    to_timeout
end

# Room list data requests

def rooms_data_url
  "https://#{valid_params[:subdomain]}.campfirenow.com/rooms.json"
end

def stub_room_list_data_request(response_code = 200)
  body = response_code == 200 ? Yajl::Encoder.encode(room_list_data_api_response) : ""
  etag_header = response_code == 200 ? {:ETag => 'new etag'} : {:ETag => etag_for_room_list_data}
  stub_request(:get, rooms_data_url).
    with(:headers => {'Authorization'=>['6124d98749365e3db2c9e5b27ca04db6', 'X'], 'Content-Type'=>'application/json', 'User-Agent' => valid_params[:user_agent], 'ETag' => etag_for_room_list_data}).
    to_return(:status => response_code, :body => body, :headers => etag_header)
end

def stub_timeout_room_list_data_request
  stub_request(:get, rooms_data_url).
    with(:headers => {'Authorization'=>['6124d98749365e3db2c9e5b27ca04db6', 'X'], 'Content-Type'=>'application/json'}, 'User-Agent' => valid_params[:user_agent]).
    to_timeout
end

def room_list_data_api_response
  {'rooms' => valid_room_cache_data.map {|key, val| val}}
end

def etag_for_room_list_data
  etag_for_data(room_list_data_api_response)
end
