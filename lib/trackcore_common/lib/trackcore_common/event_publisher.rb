require 'bunny'

module TrackcoreCommon
  class EventPublisher
    class << self
      def publish(event_name, payload)
        connection.start
        channel = connection.create_channel
        exchange = channel.fanout("trackcore.#{event_name}")
        
        exchange.publish(
          Oj.dump(payload),
          persistent: true,
          content_type: 'application/json'
        )
      ensure
        connection.close if connection
      end

      private

      def connection
        @connection ||= Bunny.new(ENV['RABBITMQ_URL'])
      end
    end
  end
end
