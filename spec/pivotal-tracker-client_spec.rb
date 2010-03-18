require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe PivotalTrackerClient do
  context "on init with a token" do
    it "should save the verstion of the latest activity" do
      client = PivotalTrackerClient.init '123456789' 
      client.version.should == 27585
    end

    it "should request the feed with the token" do
      token = '34g43g4334g43g43'
      PivotalTrackerClient.should_receive(:get) do |url, opts|
        opts[:headers]['X-TrackerToken'].should eql(token)
        latests_activities
      end
      PivotalTrackerClient.init token
    end
  end
end
