require 'httparty'
require 'tzinfo'
# Handles HTTParty interaction with eventbrite API
module Eventbrite
  EVENTBRITE_TIME_STRING = '%Y-%m-%d %H:%M:%S'
  # Sets up app to use an app key for interaction with API
  # Get your own developer key at http://www.eventbrite.com/api/key
  def self.setup(app_key = "API_KEY_REQUIRED", debug = false)
    @app_key = app_key
    @debug = debug
  end
  
  # Enable debugging (to standard out)
  def self.debug!
    @debug = true
  end
  
  # @private
  # Makes HTTParty call
  def self.call(function, opts = {})
    opts[:app_key] = @app_key
    if opts[:user].is_a? Eventbrite::User 
      # Allow passing User object instead of user auth info.
      u = opts.delete :user
      opts.merge!(u.auth)
    end 
    debug "\tSending  /#{function}\t\t(#{opts.inspect})"
    response = API.do_post("/#{function}", :query => opts)
    debug "\tResponse /#{function}\t\t#{response.inspect}"
    response
  end
  
  # @private
  # Does debugging
  def self.debug(msg)
    puts msg if debug?
  end
  
  # Returns true if debug on.
  def self.debug?
    @debug.nil? ? false : @debug
  end
  
  # @private
  # Parses a date string if it's not already a ruby time
  def self.timeparse(date)
    case date
    when Time
      date
    when String
      Time.parse(date)
    end
  end
  
  # @private
  # Formats an Eventbrite date
  def self.formatted_time(date)
    case date
    when Time
      date.strftime(EVENTBRITE_TIME_STRING)
    when String
      Time.parse(date).strftime(EVENTBRITE_TIME_STRING)
    end
  end
  
  # @private
  class API
    include HTTParty
    base_uri "https://www.eventbrite.com/json/"
    def self.do_post(function, opts = {})
      response = post(function, opts)
      if response["error"]
        raise Error.new(response["error"]["error_message"], response["error"]["error_type"], response)
      end
      response
    end
  end
end

EventBright = Eventbrite
