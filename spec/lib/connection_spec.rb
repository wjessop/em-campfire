require "users_helper"

class ConnectionTester < ModuleHarness
  include EventMachine::Campfire::Connection
  include EventMachine::Campfire::Users

  def cache; @cache ||= EventMachine::Campfire::Cache.new; end

  def receive_message(message)
    process_message(message)
  end
end

describe EventMachine::Campfire::Connection do
  before :each do
    mock_logger(ConnectionTester)
    @conn = ConnectionTester.new
  end

  it "should receive messages" do
    @conn.receive_message "foo"
    logger_output.should =~ /DEBUG.*Received message "foo"/
    logger_output.should =~ /DEBUG.*on_message callback does not exist/
  end

  it "should process on_message an block if present" do
    ping = mock
    ping.expects(:ping).with("foo")
    @conn.on_message {|message| ping.ping(message) }
    @conn.receive_message "foo"
    logger_output.should =~ /DEBUG.*on_message callback exists, calling it with "foo"/
  end

  it "should be able to ignore itself" do
    @conn.ignore_self = true
    @conn.cache.stubs(:get).with('user-data-me').returns({'id' => 789})

    ping = mock
    ping.expects(:ping).never

    @conn.on_message { ping.ping }
    EM.run_block { @conn.receive_message({:user_id => 789}) }
    logger_output.should =~ /Ignoring message with user_id 789 as that is me and ignore_self is true/
  end

  it "should not ignore non-self messages" do
    stub_self_data_request
    @conn.ignore_self = true

    ping = mock
    ping.expects(:ping).once
    @conn.on_message { ping.ping }
    EM.run_block { @conn.receive_message({:user_id => 2}) }
  end
end
