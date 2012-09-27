require "spec_helper"

describe EventMachine::Campfire::Cache do
  before :each do
    @cache = EventMachine::Campfire::Cache.new
  end

  it "should cache data" do
    @cache.set("foo", "bar")
    @cache.get("foo").should eql("bar")
  end

  it "should stringify keys" do
    @cache.set(123, "bar")
    @cache.get("123").should eql("bar")
    @cache.get(123).should eql("bar")
  end

  it "should yield cache data" do
    @cache.set(123, "bar")
    @cache.get(123) do |value|
      value
    end.should eql("bar")
  end
end
