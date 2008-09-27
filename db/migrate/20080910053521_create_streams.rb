class CreateStreams < ActiveRecord::Migration
  def self.up
    create_table :streams do |t|
      t.string :password
      t.string :blog_url
      t.string :title
      t.string :subtitle
      t.string :author
      t.string :friendfeed_url
      t.string :feedburner_feed_url
      t.string :addthis_username
      t.string :disqus_forum_identifier
      t.boolean :filter_message_without_space
      t.string :filter_tag
      t.string :default_markdown
      t.string :about
      t.timestamps
    end
    Stream.create(:password => 'dodo', 
                  :friendfeed_url => 'http://friendfeed.com/api/feed/user/dominiek?format=xml',
                  :blog_url => 'http://dev.dominiek.com/',
                  :feedburner_feed_url => 'http://feeds.feedburner.com/dominiek',
                  :title => 'Dominiek', 
                  :subtitle => 'Web, technology and startups', 
                  :addthis_username => 'dominiek', 
                  :disqus_forum_identifier => 'dominiek30')
  end

  def self.down
    drop_table :streams
  end
end
