require "messages_helper"

class MessageTester < ModuleHarness
  include EventMachine::Campfire::Messages
  include EventMachine::Campfire::Rooms
end

describe EventMachine::Campfire::Messages do
  before :each do
    @adaptor = MessageTester.new
  end
  
  describe "posting messages" do
    it "should say" do
      @adaptor.expects(:send_message).with(123, "foo", "TextMessage")
      @adaptor.say("foo", 123)
    end

    it "should paste" do
      @adaptor.expects(:send_message).with(123, "foo", "PasteMessage")
      @adaptor.paste("foo", 123)
    end

    it "should play" do
      @adaptor.expects(:send_message).with(123, "foo", "SoundMessage")
      @adaptor.play("foo", 123)
    end
  end

  it "should not try to post a message to a room it hasn't joined" do
    mock_logger(MessageTester)
    EM.run_block { @adaptor.say "Hi", 123 }

    logger_output.should =~ %r{Couldn't post message "Hi" to room 123 as no rooms have been joined}
  end

  context "having successfully joined a room" do
    before :each do
      mock_logger(MessageTester)
      stub_join_room_request(123)
      EM.run_block { @adaptor.join(123) }
    end

    it "should say a message" do
      stub = stub_message_post_request
      EM.run_block { @adaptor.say("Hi", 123) }
      stub.should have_been_requested
      logger_output.should =~ /DEBUG.*Posted TextMessage "Hi" to room 123/
    end

    it "should handle message posting failure" do
      stub = stub_message_post_request(500)
      EM.run_block { @adaptor.say("Hi", 123) }
      stub.should have_been_requested
      logger_output.should =~ %r{ERROR.*Couldn't post message "Hi" to room 123 using url https://oxygen.campfirenow.com/room/123/speak.json, http response from the API was 500}
    end
  end
end
