require "spec_helper"

describe EventMachine::Campfire::Connection do
    
  context "#on_message" do
    before :each do
      EM.run_block { @adaptor = a EM::Campfire }
    end
      
    it "run a block when it receives a message"
  end
end
