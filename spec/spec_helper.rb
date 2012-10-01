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

def etag_for_data(data)
  "\"#{Digest::SHA2.hexdigest(data.to_s)}\""
end

def valid_params
  {:api_key => "6124d98749365e3db2c9e5b27ca04db6", :subdomain => "oxygen"} 
end



class ModuleHarness
  def subdomain; valid_params[:subdomain]; end
  def api_key; valid_params[:api_key]; end
end