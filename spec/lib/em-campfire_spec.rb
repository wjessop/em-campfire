require "spec_helper"

describe EventMachine::Campfire do
  
  before :each do
    @self_data_request_stub = stub_self_data_request
  end
    
  describe "#initialize" do
    it "should work with valid params" do
      EM.run_block { a(EM::Campfire).should be_a(EM::Campfire) }
    end
    
    it "should raise when given an option it doesn't understand" do
      lambda { EM::Campfire.new(valid_params.merge({:fred => "estaire"}))}.should raise_error(ArgumentError, ":fred is not a valid option")
    end
    
    it "should require essential parameters" do
      lambda { EM::Campfire.new }.should raise_error(ArgumentError, "You must pass an API key")
      lambda { EM::Campfire.new(:api_key => "foo") }.should raise_error(ArgumentError, "You must pass a subdomain")
    end

    it "should fetch data about me" do
      EM.run_block { a(EM::Campfire).should be_a(EM::Campfire) }
      @self_data_request_stub.should have_been_requested
    end
  end
  
  describe "#verbose" do
    it "should default to false" do
      EM.run_block { a(EM::Campfire).verbose.should be_false }
    end
    
    it "should be overridable at initialization" do
      EM.run_block { a(EM::Campfire, :verbose => true).verbose.should be_true }
    end
  end
  
  describe "#logger" do
    context "default logger" do
      before { EM.run_block { @adaptor = a EM::Campfire } }
      
      it { @adaptor.logger.should be_a(Logger) }
      it { @adaptor.logger.level.should be == Logger::INFO }
    end
    
    context "default logger in verbose mode" do
      before { EM.run_block { @adaptor = a EM::Campfire, :verbose => true } }
      
      it { @adaptor.logger.level.should be == Logger::DEBUG }
    end
    
    context "overriding default" do
      before do
        @custom_logger = Logger.new("/dev/null")
        EM.run_block { @adaptor = a EM::Campfire, :logger => @custom_logger }
      end
      
      it { @adaptor.logger.should be == @custom_logger }
    end
  end

  describe "#cache" do
    before :each do
      EM.run_block { @adaptor = a EM::Campfire }
      @valid_cache_stub = stub(:get => "foo", :set => nil, :respond_to => true)
    end

    it "should accept a valid cache object" do
      @adaptor.cache = @valid_cache_stub
      @adaptor.cache.set
      @adaptor.cache.get.should eql("foo")
    end

    it "should reject a cache object that doesn't have a conforming interface" do
      lambda { @adaptor.cache = stub(:respond_to) }.should raise_error(ArgumentError, "You must pass a conforming cache object")
    end

    it "should provide a default cache" do
      @adaptor.cache.set("foo", "bar")
      @adaptor.cache.get("foo").should eql("bar")
    end
  end

  describe "#ignore_timestamps" do
    before :each do
      EM.run_block { @adaptor = a EM::Campfire }
    end

    it "should default to false" do
      @adaptor.ignore_timestamps?.should eql(false)
    end

    it "should be overridable at initialization" do
      EM.run_block { a(EM::Campfire, :ignore_timestamps => true).ignore_timestamps?.should be_true }
    end
  end

  describe "#user_agent" do
    before :each do
      EM.run_block { @adaptor = a EM::Campfire }
    end

    it "should default to em-campfire" do
      @adaptor.user_agent.should eql("em-campfire")
    end

    it "should be overridable at initialization" do
      @self_data_request_stub = stub_override_user_agent_self_data_request
      EM.run_block { a(EM::Campfire, :user_agent => "testing/1.0").user_agent.should eql("testing/1.0") }
    end
  end
end

