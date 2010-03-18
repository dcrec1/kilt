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

  context "on fetch" do
    before :each do
      @client = PivotalTrackerClient.init('fake')
      @client.stub! :system
    end

    it "should get the feed from the current version and update the version" do
      @client.fetch
      @client.version.should == 28585
    end

    context "on os x" do
      it "should notifify growl about each activity" do
        @client.should_receive(:system).exactly(2).times
        @client.fetch
      end

      it "should notify growl calling growlnotify with 'Pivotal Tracker' as the name the application, the author and the action" do
        @client.should_receive(:system).with('growlnotify -t Pivotal Tracker -m Superman finished lorem ipsum')
        @client.fetch
      end

      it "should notify newer activities at least" do
        @client.should_receive(:system).with('growlnotify -t Pivotal Tracker -m Spiderman edited lorem ipsum').ordered
        @client.should_receive(:system).with('growlnotify -t Pivotal Tracker -m Superman finished lorem ipsum').ordered
        @client.fetch
      end
    end
  end
end
