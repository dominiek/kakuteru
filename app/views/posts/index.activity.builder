xml.instruct!(:xml, :version => "1.0")
xml.feed(:xmlns => "http://www.w3.org/2005/Atom", :activity => "http://activitystrea.ms/spec/1.0/") do |feed|
  feed.title(@title)
  feed.id("tag:#{request.host},#{Time.now.year}:#{APPLICATION_NAME}")
  feed.link(:href => "http://#{request.host_with_port}/", :rel => "alternate", :type => "text/html")
  feed.link(:href => "http://#{request.host_with_port}#{request.request_uri}", :rel => "self", :type => "application/atom+xml")
  feed.updated(@posts.first.published_at.iso8601) if @posts.first
  feed.generator(APPLICATION_NAME, :uri => 'http://dominiek.com/tag/maitako')
  @posts.each do |post|
    feed.entry do |entry|
      entry.id("tag:#{request.host},#{Time.now.strftime("%Y-%m-%d")}:#{APPLICATION_NAME}")
      entry.title(h(post.caption))
      entry.content(:type => 'html') do
        entry.cdata!(render(:partial => "posts/#{post.type}.html.erb", :locals => {:post => post}))
      end
      entry.published(post.published_at.iso8601) if post.published_at
      post.tag_list.each do |tag|
        entry.category(:term => tag)
      end
      entry.link(:href => read_url(:id => post), :type => "text/html", :rel => "alternate")
      entry.author do |author|
        author.name(@stream.author)
      end
      entry.tag!('activity:verb', 'post')
      medias = post.medias
      unless medias.blank?
        object = medias.first
        entry.tag!('activity:object') do |activity_object|
          activity_object.id("tag:#{request.host},#{Time.now.strftime("%Y-%m-%d")}:#{post.type}_#{object.id}")
          activity_object.title(h(object.caption))
          activity_object.published(object.created_at)
          activity_object.tag!('activity:object-type', post.type)
          activity_object.link(:href => object.url, :type => "text/html", :rel => "alternate")
          activity_object.source do |source|
            source.title("#{@stream.author} on #{post.service.name}")
            source.link(:href => post.service.profile_url, :type => "text/html", :rel => "alternate")
          end
        end
      end
    end
  end
end

=begin
<entry>
   <id>tag:photopanic.example.com,2008:activity01</id>
   <title>Geraldine posted a Photo on PhotoPanic</title>
   <published>2008-11-02T15:29:00Z</published>
   <link rel="alternate" type="text/html"
         href="/geraldine/activities/1" />
   <activity:verb>
      http://activitystrea.ms/schema/1.0/post
   </activity:verb>
   <activity:object>
      <id>tag:photopanic.example.com,2008:photo01</id>
      <title>My Cat</title>
      <published>2008-11-02T15:29:00Z</published>
      <link rel="alternate" type="text/html"
            href="/geraldine/photos/1" />
      <activity:object-type>
          tag:atomactivity.example.com,2008:photo
      </activity:object-type>
      <source>
          <title>Geraldine's Photos</title>
          <link rel="self" type="application/atom+xml"
                href="/geraldine/photofeed.xml" />
          <link rel="alternate" type="text/html"
                href="/geraldine/" />
      </source>
   </activity:object>
</entry>
=end