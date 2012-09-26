require 'eventmachine'
require 'em-http-request'
require 'yajl'
require "logger"

require "em-campfire/version"
require "em-campfire/connection"
require "em-campfire/rooms"
require "em-campfire/users"
require "em-campfire/messages"

module EventMachine
  class Campfire
    attr_accessor :logger, :verbose, :subdomain, :api_key
    
    include Connection
    include Rooms
    include Users
    include Messages
    
    def initialize(options = {})
      raise ArgumentError, "You must pass an API key" unless options[:api_key]
      raise ArgumentError, "You must pass a subdomain" unless options[:subdomain]
      
      options.each do |k,v|
        s = "#{k}="
        if respond_to?(s)
          send(s, v)
        else
          logger.warn "em-campfire initialized with #{k.inspect} => #{v.inspect} but NO UNDERSTAND!"
        end
      end
      
      @rooms = {}
      @room_cache = {}
    end
        
    def logger
      unless @logger
        @logger = Logger.new(STDOUT)
        @logger.level = (verbose ? Logger::DEBUG : Logger::INFO)
      end
      @logger
    end

    def verbose=(is_verbose)
      @verbose = is_verbose
      logger.level = Logger::DEBUG if is_verbose
    end
  end # Campfire
end # EventMachine
