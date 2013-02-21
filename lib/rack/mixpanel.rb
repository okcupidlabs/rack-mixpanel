require 'base64'
require 'json'
require 'open-uri'

require 'rack'

module Rack
  class Mixpanel
    def initialize(app, token=nil)
      @app = app
      @token = token || ENV['MIXPANEL_API_TOKEN']
    end

    def call(env)
      request = Rack::Request.new(env)
      mp_cookie = request.cookies["mp_#{@token}_mixpanel"]
      if mp_cookie
        mp_env = JSON.parse(mp_cookie)
        distinct_id = mp_env['distinct_id']
        env['mixpanel.distinct_id'] = distinct_id
      end
      env['mixpanel.tracker'] = Tracker.new(@token, request.ip, env['mixpanel.distinct_id'])
      @app.call(env)
    end

    class Tracker
      attr_reader :thread
      def initialize(token, ip, distinct_id)
        @token = token
        @ip = ip
        @distinct_id = distinct_id
      end

      def track(event, properties)
        base_props = {
          'token' => @token,
          'ip' => @ip,
          'distinct_id' => @distinct_id
        }
        enc_props = Base64.encode64 JSON.generate({'event' => event, 'properties' => base_props.merge(properties)})
        uri = URI('https://api.mixpanel.com/track')
        uri.query = URI.encode_www_form(:data => enc_props)
        @thread = Thread.new { uri.read }
        nil
      end
    end
  end
end

