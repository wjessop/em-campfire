require 'spec_helper'

def valid_user_cache_data
  {123 => {"name" => "foo"}, 456 => {"name" => "bar"}, 'me' => {"name" => "bot", "id" => 789}}
end

# Fetching data about users

def stub_user_data_request(user_id, response_code = 200)
  body = response_code == 200 ? Yajl::Encoder.encode(:user => valid_user_cache_data[user_id]) : ""
  stub_request(:get, "https://#{valid_params[:subdomain]}.campfirenow.com/users/#{user_id}.json").
    with(:headers => {'Authorization'=>['6124d98749365e3db2c9e5b27ca04db6', 'X'], 'Content-Type'=>'application/json', 'User-Agent' => valid_params[:user_agent]}).
    to_return(:status => response_code, :body => body, :headers => {:ETag => etag_for_data(valid_user_cache_data[user_id])})
end

def stub_timeout_user_data_request(user_id)
  stub_request(:get, "https://#{valid_params[:subdomain]}.campfirenow.com/users/#{user_id}.json").
    with(:headers => {'Authorization'=>['6124d98749365e3db2c9e5b27ca04db6', 'X'], 'Content-Type'=>'application/json', 'User-Agent' => valid_params[:user_agent]}).
    to_timeout
end

# Fetching data about self

def stub_self_data_request(response_code = 200)
  body = response_code == 200 ? Yajl::Encoder.encode(:user => valid_user_cache_data['me']) : ""
  stub_request(:get, "https://#{valid_params[:subdomain]}.campfirenow.com/users/me.json").
    with(:headers => {'Authorization'=>['6124d98749365e3db2c9e5b27ca04db6', 'X'], 'Content-Type'=>'application/json', 'User-Agent' => valid_params[:user_agent]}).
    to_return(:status => response_code, :body => body, :headers => {:ETag => etag_for_data(valid_user_cache_data['me'])})
end

def stub_override_user_agent_self_data_request(response_code = 200)
  body = response_code == 200 ? Yajl::Encoder.encode(:user => valid_user_cache_data['me']) : ""
  stub_request(:get, "https://#{valid_params[:subdomain]}.campfirenow.com/users/me.json").
    with(:headers => {'Authorization'=>['6124d98749365e3db2c9e5b27ca04db6', 'X'], 'Content-Type'=>'application/json', 'User-Agent' => 'testing/1.0'}).
    to_return(:status => response_code, :body => body, :headers => {:ETag => etag_for_data(valid_user_cache_data['me'])})
end

def stub_timeout_self_data_request
  stub_request(:get, "https://#{valid_params[:subdomain]}.campfirenow.com/users/me.json").
    with(:headers => {'Authorization'=>['6124d98749365e3db2c9e5b27ca04db6', 'X'], 'Content-Type'=>'application/json', 'User-Agent' => valid_params[:user_agent]}).
    to_timeout
end
