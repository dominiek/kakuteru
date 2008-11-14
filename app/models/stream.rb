
class Stream < ActiveRecord::Base
  has_many :posts, :conditions => 'is_deleted IS FALSE', :order => 'published_at DESC'
  has_many :articles, 
    :include => [:service],
    :conditions => "is_deleted IS FALSE AND is_draft IS FALSE AND services.identifier = 'articles'", 
    :order => 'published_at DESC', 
    :class_name => 'Post'
  has_many :drafts, 
    :include => [:service],
    :conditions => "is_deleted IS FALSE AND is_draft IS TRUE  AND services.identifier = 'articles'", 
    :order => 'posts.created_at DESC', 
    :class_name => 'Post'
  has_many :media_posts,
    :include => [:medias, :service],
    :conditions => "is_deleted IS FALSE AND medias.id IS NOT NULL AND services.identifier != 'wakoopa'",
    :order => 'posts.published_at DESC', 
    :class_name => 'Post',
    :limit => 4
  has_many :services do
    def public(options = {})
      find(:all, options.merge(:conditions => "is_enabled IS TRUE AND identifier != 'blog'"))
    end
  end
  has_many :upcoming_trips,
    :conditions => "travel_starts_at > NOW()",
    :class_name => 'Trip',
    :limit => 8
  
  def authenticate(password)
    if self.password == password
      true
    else
      self.errors.add(:password, 'Invalid password mate!')
      false
    end
  end
  
  def self.current
    self.find_or_create_by_id(1)
  end
  
  def activity_overview_graph
    require 'google_chart'
    # Main Activity Chart
    GoogleChart::BarChart.new('900x300', "Daily Activity", :vertical, false) do |bc|
      data = {}
      services = []
      self.posts.find(:all, 
                         :select => 'COUNT(posts.id) AS num_posts, service_id, published_at', 
                         :conditions => ['posts.published_at > ?', 2.weeks.ago],
                         :group => "service_id,DATE_FORMAT(posts.published_at, '%Y-%m-%d')").each do |post|
        xlabel = post.published_at.beginning_of_day
        data[xlabel] = {} unless data[xlabel]
        data[xlabel][post.service_id.to_i] = post.num_posts.to_i
        services << post.service_id.to_i unless services.include?(post.service_id.to_i)
      end
      xlabels = []
      data_by_service = {}
      all_values = []
      data = data.to_a
      data.sort! { |a,b| a.first.to_i <=> b.first.to_i }
      data.each do |date,posts_by_service|
        xlabels << date.strftime("%b-%d")
        total_today = 0
        services.each do |service_id|
          data_by_service[service_id] ||= []
          data_by_service[service_id] << (posts_by_service[service_id] || 0)
          total_today += posts_by_service[service_id].to_i
        end
        all_values << total_today
      end
      color_i = 0
      services.sort!
      services.reverse!
      services.each do |service_id|
        bc.data(Service.find(service_id).identifier, data_by_service[service_id], graph_colors[(color_i % 4)])
        color_i += 1 
      end
      ylabels = []
      0.upto(all_values.max) { |i| ylabels << i }
      #1.upto(10) { |i| ylabels << i }
      bc.axis(:y, :labels => ylabels)
      bc.axis(:x, :labels => xlabels)
      bc.width_spacing_options(:bar_width => 50)
      bc.stacked = true
      return bc    
    end    
  end
  
  def used_services_graph
    require 'google_chart'
    # Services Diagram
    services = {}
    self.posts.find(:all,
                       :select => 'COUNT(posts.id) AS num_posts,service_id',
                       :conditions => ['posts.published_at > ?', 2.weeks.ago],
                       :group => 'service_id').each do |post|
      services[post.service_id.to_i] = post.num_posts.to_i
    end
    GoogleChart::PieChart.new('320x200', "Services used", false) do |pc|
      color_i = 0
      services = services.to_a.sort! { |b,a| a.first <=> b.first }
      services.each do |service_id,num_posts|
        pc.data(Service.find(service_id).identifier, num_posts, graph_colors[(color_i % 4)])
        color_i += 1
      end
      return pc
    end
  end
  
  def common_activity_hours_graph_url
    require 'google_chart'
    hourly_activity = {}
    time_zone = nil
    self.posts.find(:all, 
                       :select => 'COUNT(posts.id) AS num_posts,published_at',
                       :conditions => ['posts.published_at > ?', 2.weeks.ago],
                       :group => "DATE_FORMAT(posts.published_at, '%H')").each do |post|
      hourly_activity[post.published_at.strftime("%H").to_i] = post.num_posts.to_i
    end
    puts hourly_activity.inspect
    xlabels = (0..23).collect { |h| "#{h+1}:00" }
    hourly_activity = (0..23).collect { |h| hourly_activity[h] || 0 }
    hourly_activity = hourly_activity.collect { |p| ((p/hourly_activity.max.to_f)*100).ceil }
    "http://chart.apis.google.com/chart?cht=r&chs=200x200&chd=t:#{hourly_activity.join(',')}0&chco=#{graph_colors.first}&chls=2.0,4.0,0.0&chxt=x&chxl=0:|#{(0..23).collect { |i| i.to_s }.join('|')}&chxr=0,0.0,23.0&chm=B,#{graph_colors.last},0,1.0,4.0&chtt=Hourly+Activity+#{time_zone}"
  end
  
  def activity_summary_sparkline_url
    data = {}
    self.posts.find(:all, 
                    :select => 'COUNT(posts.id) AS num_posts, published_at', 
                    :conditions => ['posts.published_at > ?', 2.weeks.ago],
                    :group => "DATE_FORMAT(posts.published_at, '%Y-%m-%d')").each do |post|
      data[post.published_at.beginning_of_day] = post.num_posts.to_i
    end
    data = data.to_a
    data.sort! { |a,b| a.first <=> b.first }
    data = data.collect { |d| d.last }
    peak = data.max
    data = data.collect { |p| ((p/peak.to_f)*100).ceil }
    "http://chart.apis.google.com/chart?chs=200x80&chd=t:#{data.join(',')}&cht=ls"
  end
  
  protected
  
  def graph_colors
    ['2a2a2a', '666666', '999999', 'cccccc']
  end

end
