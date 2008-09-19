
posts = []
dump_file = 'articles.yml'


if ARGV.first != 'load_dump'
  # Step 1, dump mephisto articles
  ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['migrate_from_mephisto'])
  ActiveRecord::Migration.rename_column(:contents, :type, :content_type)
  class Content < ActiveRecord::Base; 
    acts_as_taggable
  end
  Content.find_by_sql("SELECT * FROM contents WHERE content_type = 'Article' AND published_at IS NOT NULL").each do |article|
    posts << {:published_at => article.published_at, 
              :body => article.body, 
              :permalink => article.permalink, 
              :caption => article.title,
              :markup => article.filter.blank? ? 'textile' : article.filter.split('_').first,
              :tag_list => article.tag_list.join(', ')}
  end
  ActiveRecord::Migration.rename_column(:contents, :content_type, :type)
  File.open(dump_file, "w").write(YAML::dump(posts))
else
  # Step 2, load mephisto dumped articles into current RAILS_ENV
  posts = YAML::load(File.open(dump_file).read)
  #ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[RAILS_ENV])
  service = Service.find_or_create_by_identifier('articles')
  posts.each do |post_hash|
    post = Post.find_by_caption(post_hash[:caption])
    if post
      post.update_attributes(post_hash.merge(:service_id => service.id, :stream_id => Stream.current.id))  
    else
      post = Post.create(post_hash.merge(:service_id => service.id, :stream_id => Stream.current.id, :is_draft => false))
    end
  end
end