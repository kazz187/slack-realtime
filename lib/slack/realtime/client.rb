require 'slack/realtime/connection'

module Slack
  module Realtime
    class Client
      def initialize(options = {})
        @options = options
        @on = {}
      end

      def connect
        message_handler = ->(data){
          case data['type']
            when 'message'
              on_block(:message).call(data)
            when 'user_typing'
              on_block(:user_typing).call(data)
            else
          end
        }
        connection.connect(&message_handler)
      end

      def on(event_name, &block)
        @on[event_name] = block
      end

      def say(options)
        @id ||= 1
        data = {
            'id' => @id += 1,
            'type' => 'message',
            'text' => options[:text],
            'channel' => options[:channel],
        }
        connection.send(data)
      end

      private
      def connection
        @connection ||= Slack::Realtime::Connection.new(team: @options[:team], token: @options[:token])
      end

      def on_block(event_name)
        @on[event_name] ||= ->(data){}
      end
    end
  end
end
