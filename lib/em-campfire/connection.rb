module EventMachine
  class Campfire
    module Connection
      attr_accessor :ignore_self

      def on_message &blk
        @on_message_block = blk
      end

      private

      attr_accessor :on_message_block

      def process_message(msg)
        return if (msg[:type] == "TimestampMessage" && ignore_timestamps?)
        logger.debug "Received message #{msg.inspect}"
        if ignore_self && is_me?(msg[:user_id])
          logger.debug "Ignoring message with user_id #{msg[:user_id]} as that is me and ignore_self is true"
        else
          if on_message_block
            on_message_block.call(msg)
          else
            logger.debug "on_message callback does not exist"
          end
        end
      end
    end
  end
end
