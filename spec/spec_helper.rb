require 'rubygems'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'pivotal-tracker-client'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  
end

def latests_activities
  File.open(File.join(File.dirname(__FILE__), 'data', 'latests_activities.xml')).read
end

require 'fakeweb'

FakeWeb.register_uri(:get, "http://www.pivotaltracker.com/services/v3/activities?limit=10", :body => latests_activities)
