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
        activity['stories'] and activity['stories'][0] and (id = activity['stories'][0]['id'])
        notify_about activity['description'], id
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

  def notify_about(message, id=nil)
    title = 'Pivotal Tracker'
    case RUBY_PLATFORM
    when /linux/
      system "notify-send '#{title}' '#{message}' --icon #{Kilt::ICON}"
    when /darwin/
      if defined?(NO_FORK)
        osx_notify(title, message, id)
      else
        # fork here so that the child process can wait for a click, but
        # the main process can continue to display notifications
        # growlnotify bug - the user must click within 10 seconds for the process
        # to return "successfully" - see:
        # http://groups.google.com/group/growldiscuss/browse_thread/thread/9b5af76d3c1667d9
        fork do
          osx_notify(title, message, id)
          exit
        end
      end
    when /mswin|mingw|win32/
      Snarl.show_message title, message, Kilt::ICON
    end
  end

  def osx_notify(title, message, id)
    system "growlnotify -t -w -s '#{title}' -m '#{message}' --image #{Kilt::ICON}"
    # if the return code is greater than 0 it was clicked before 10s
    # only handle the click its a valid tracker id
    if id and $?.to_i > 0
      system "open https://www.pivotaltracker.com/story/show/#{id}"
    end
  end
end
