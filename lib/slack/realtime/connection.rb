require 'httpclient'
require 'json'
require 'faye/websocket'
require 'eventmachine'

module Slack
  module Realtime
    class Connection
      RTM_AUTH_URL = 'https://slack.com/api/rtm.start'

      def initialize(options = {})
        @options = options
      end

      def connect(&message_handler)
        EM.run {
          @ws = Faye::WebSocket::Client.new(wss_url)

          @ws.on :open do |event|
            p [:open]
          end

          @ws.on :message do |event|
            data = JSON.parse(event.data)
            message_handler.call(data)
            p [:message, data]
          end

          @ws.on :close do |event|
            p [:close, event.code, event.reason]
            # TODO: reconnect
          end
        }
      end

      def send(data)
        @ws.send(data.to_json)
      end

   private
      def wss_url
        @wss_url ||= -> {
          post_data = {'token' => @options[:token]}
          client = HTTPClient.new
          result = JSON.parse(client.post(RTM_AUTH_URL, post_data).content)
          result['url']
        }.call
      end

    end
  end
end