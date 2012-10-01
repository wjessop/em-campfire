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
        logger.debug "Received message #{msg.inspect}"

        message_handler = lambda {
          if on_message_block
            logger.debug "on_message callback exists, calling it with #{msg.inspect}"
            on_message_block.call(msg)
          else
            logger.debug "on_message callback does not exist"
          end
        }

        if ignore_self
          is_me?(msg[:user_id], &message_handler)
        else
          message_handler.call
        end
      end
    end
  end
end
