require 'httparty'
require 'crack/xml'

class PivotalTrackerClient
  include HTTParty

  attr_reader :version

  def self.init(token) 
    new get('http://www.pivotaltracker.com/services/v3/activities?limit=10', :headers => {'X-TrackerToken' => token})
  end

  protected

  def initialize(response)
    @version = Crack::XML.parse(response)['activities'].first['version']
  end
end
