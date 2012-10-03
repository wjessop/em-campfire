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
    @conn = ConnectionTester.new
  end

  it "should alert if on_message callback doesn't exist" do
    mock_logger(ConnectionTester)
    @conn.receive_message({:type=>"TextMessage"})
    logger_output.should =~ /DEBUG.*on_message callback does not exist/
  end

  it "should process on_message an block if present" do
    mock_logger(ConnectionTester)
    ping = mock
    ping.expects(:ping).with({:type=>"TextMessage"})
    @conn.on_message {|message| ping.ping(message) }
    @conn.receive_message({:type=>"TextMessage"})
  end

  it "should be able to ignore itself" do
    mock_logger(ConnectionTester)
    @conn.ignore_self = true
    @conn.cache.stubs(:get).with('user-data-me').returns({'id' => 789})

    ping = mock
    ping.expects(:ping).never

    @conn.on_message { ping.ping }
    EM.run_block { @conn.receive_message({:user_id => 789, :type=>"TextMessage"}) }
    logger_output.should =~ /Ignoring message with user_id 789 as that is me and ignore_self is true/
  end

  it "should not ignore non-self messages" do
    mock_logger(ConnectionTester)
    stub_self_data_request
    @conn.ignore_self = true

    ping = mock
    ping.expects(:ping).once
    @conn.on_message { ping.ping }
    EM.run_block { @conn.receive_message({:user_id => 2}) }
  end

  it "should be able to ignore timestamps" do
    @conn.expects(:ignore_timestamps?).returns(true)
    ping = mock
    ping.expects(:ping).never
    @conn.on_message {|message| ping.ping }
    @conn.receive_message({:room_id=>410261, :created_at=>"2012/10/03 22:55:00 +0000", :body=>nil, :starred=>false, :id=>688112871, :user_id=>nil, :type=>"TimestampMessage"})
  end
end
