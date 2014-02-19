require 'eventmachine'
require 'em-http-request'
require 'yajl'
require "logger"

require "em-campfire/version"
require "em-campfire/connection"
require "em-campfire/rooms"
require "em-campfire/users"
require "em-campfire/messages"
require "em-campfire/cache"

module EventMachine
  class Campfire
    attr_accessor :logger, :verbose, :subdomain, :api_key, :ignore_timestamps
    
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
          raise ArgumentError, "#{k.inspect} is not a valid option"
        end
      end

      fetch_user_data_for_self
    end

    def cache=(a_cache)
      raise(ArgumentError, "You must pass a conforming cache object") unless a_cache.respond_to(:set) && a_cache.respond_to(:get)
      @cache = a_cache
    end

    def cache
      @cache ||= EventMachine::Campfire::Cache.new
    end

    def logger
      unless @logger
        @logger = Logger.new(STDOUT)
        @logger.level = (verbose ? Logger::DEBUG : Logger::INFO)
        @logger.info "em-campfire using default logger as none was provided"
      end
      @logger
    end

    def verbose=(is_verbose)
      @verbose = is_verbose
      logger.level = Logger::DEBUG if is_verbose
    end

    def ignore_timestamps?
      self.ignore_timestamps || false
    end
  end # Campfire
end # EventMachine
