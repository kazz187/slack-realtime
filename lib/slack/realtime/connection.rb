require 'httpclient'
require 'json'
require 'faye/websocket'
require 'eventmachine'

module Slack
  module Realtime
    class Connection
      API_URL = 'https://slack.com/api'

      def initialize(options = {})
        @options = options
        @users = {}
        @channels = {}
        @channel_ids = {}
      end

      def connect(&message_handler)
        EM.run {
          @ws = Faye::WebSocket::Client.new(wss_url)

          @ws.on :open do |event|
          end

          @ws.on :message do |event|
            data = JSON.parse(event.data)
            message_handler.call(resolve_name(data))
          end

          @ws.on :close do |event|
            p [:close, event.code, event.reason]
            # TODO: reconnect
          end
        }
      end

      def send(ch_name, data)
        data['channel'] = channel_id(ch_name)
        @ws.send(data.to_json)
      end

   private
      def wss_url
        @wss_url ||= -> {
          response = slack_post("#{API_URL}/rtm.start")
          response['url']
        }.call
      end

      def resolve_name(orig_data)
        resolved_data = Marshal.load(Marshal.dump(orig_data))
        orig_data.each do |k, v|
          case k
            when 'user'
              resolved_data['user_name'] = user_name(v)
            when 'channel'
              resolved_data['channel_name'] = channel_name(v)
            else
          end
        end
        resolved_data
      end

      def user_name(user_id)
        return @users[user_id] if @users.key?(user_id)
        response = slack_post("#{API_URL}/users.info", {user: user_id})
        response['ok'] ? @users[user_id] = response['user']['name'] : ''
      end

      def channel_name(channel_id)
        return @channels[channel_id] if @channels.key?(channel_id)
        response = slack_post("#{API_URL}/channels.info", {channel: channel_id})
        if response['ok']
          @channel_ids[response['channel']['name']] = channel_id
          @channels[channel_id] = response['channel']['name']
        else
          ''
        end
      end

      def channel_id(name)
        @channel_ids.key?(name) ? @channel_ids[name] : ''
      end

      def slack_post(url, data = {})
        data['token'] = @options[:token]
        @client ||= HTTPClient.new
        JSON.parse(@client.post(url, data).content)
      end
    end
  end
end