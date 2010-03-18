require 'httparty'
require 'crack/xml'
require 'rufus/scheduler'

class PivotalTrackerClient
  include HTTParty
  include Crack

  attr_reader :version

  def self.init(token) 
    new token
  end

  def fetch
    data = update_by "newer_than_version=#{@version}"
    data['activities'].reverse.each do |activity|
      system "growlnotify -t 'Pivotal Tracker' -m '#{activity['description']}'"
    end
  end

  protected

  def initialize(token)
    @token = token
    update_by 'limit=10'
    Rufus::Scheduler.start_new.every('30s') { fetch }
  end

  private

  def update_by(qs)
    xml = XML.parse(self.class.get("http://www.pivotaltracker.com/services/v3/activities?#{qs}", :headers => {'X-TrackerToken' => @token}))
    @version = xml['activities'].first['version']
    return xml
  end
end
