require 'simplecov'
require 'digest'

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

def etag_for_data(data)
  "\"#{Digest::SHA2.hexdigest(data.to_s)}\""
end

def valid_params
  {:api_key => "6124d98749365e3db2c9e5b27ca04db6", :subdomain => "oxygen"} 
end

def stub_user_data_request(user_id, response_code = 200)
  body = response_code == 200 ? Yajl::Encoder.encode(:user => valid_user_cache_data[user_id]) : ""
  stub_request(:get, "https://#{valid_params[:subdomain]}.campfirenow.com/users/#{user_id}.json").
    with(:headers => {'Authorization'=>['6124d98749365e3db2c9e5b27ca04db6', 'X'], 'Content-Type'=>'application/json'}).
    to_return(:status => response_code, :body => body, :headers => {:ETag => etag_for_data(valid_user_cache_data[user_id])})
end

def stub_timeout_user_data_request(user_id)
  stub_request(:get, "https://#{valid_params[:subdomain]}.campfirenow.com/users/#{user_id}.json").
    with(:headers => {'Authorization'=>['6124d98749365e3db2c9e5b27ca04db6', 'X'], 'Content-Type'=>'application/json'}).
    to_timeout
end

class ModuleHarness
  def subdomain; valid_params[:subdomain]; end
  def api_key; valid_params[:api_key]; end
end