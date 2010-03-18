require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe PivotalTrackerClient do
  context "on init with a token" do
    it "should save the verstion of the latest activity" do
      client = PivotalTrackerClient.init '123456789' 
      client.version.should == 27585
    end
  end
end
