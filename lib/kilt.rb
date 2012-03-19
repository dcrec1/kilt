require 'rest_client'
require 'crack/xml'
require 'rufus/scheduler'
require 'snarl' if RUBY_PLATFORM =~ /mswin|mingw|win32/

class Kilt
  include Crack

  attr_reader :id

  ICON = File.expand_path(File.join(File.dirname(__FILE__), '..', 'img', 'pivotal.png'))

  def self.init(token, skip_author=nil)
    new(token, skip_author)
  end

  def update
    activities = fetch_activities
    activities.reverse.each do |activity|
      if activity['id'] > @id.to_i && activity['author'] != @skip_author
        notify_about activity['description']
      end
    end
    update_id_from activities
  end

  protected

  def initialize(token, skip_author)
    @token = token
    @skip_author = skip_author
    update_id_from fetch_activities
    Rufus::Scheduler.start_new.every('30s') { update }
  end

  private

  def update_id_from(activities)
    @id = activities.first['id'].to_s
  end

  def fetch_activities
    return XML.parse(RestClient.get("http://www.pivotaltracker.com/services/v3/activities?limit=10",
                                    'X-TrackerToken' => @token).body)['activities']
  end

  def notify_about(message)
    title = 'Pivotal Tracker'
    case RUBY_PLATFORM
    when /linux/
      system "notify-send '#{title}' '#{message}' --icon #{Kilt::ICON}"
    when /darwin/
      system "growlnotify -t '#{title}' -m '#{message}' --image #{Kilt::ICON}"
    when /mswin|mingw|win32/
      Snarl.show_message title, message, Kilt::ICON
    end
  end

end
