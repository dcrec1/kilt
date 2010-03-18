require 'rest_client'
require 'crack/xml'
require 'rufus/scheduler'

class PivotalTrackerClient
  include Crack

  attr_reader :id

  def self.init(token) 
    new token
  end

  def update
    activities = fetch_activities
    activities.reverse.each do |activity|
      if activity['id'] > @id.to_i
        system "growlnotify -t 'Pivotal Tracker' -m '#{activity['description']}'"
      end
    end
    update_id_from activities
  end

  protected

  def initialize(token)
    @token = token
    update_id_from fetch_activities
    Rufus::Scheduler.start_new.every('30s') { update }
  end

  private

  def update_id_from(activities)
    @id = activities.first['id'].to_s
  end

  def fetch_activities
    return XML.parse(RestClient.get("http://www.pivotaltracker.com/services/v3/activities?limit=10", 'X-TrackerToken' => @token).body)['activities']
  end
end
