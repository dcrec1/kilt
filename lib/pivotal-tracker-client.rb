require 'httparty'
require 'crack/xml'

class PivotalTrackerClient
  include HTTParty

  attr_reader :version

  def self.init(token) 
    new token
  end

  def fetch
    data = update_by "newer_than_version=#{@version}"
    data['activities'].each do |activity|
      system ''
    end
  end

  protected

  def initialize(token)
    @token = token
    update_by 'limit=10'
  end

  private

  def update_by(qs)
    xml = Crack::XML.parse(self.class.get("http://www.pivotaltracker.com/services/v3/activities?#{qs}", :headers => {'X-TrackerToken' => @token}))
    @version =  xml['activities'].first['version']
    return xml
  end
end
