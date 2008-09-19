xml.instruct!(:xml, :version => "1.0")
xml.feed(:xmlns => "http://www.w3.org/2005/Atom") do |feed|
  feed.title("#{@stream.title} - #{@stream.subtitle}")
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
      entry.updated(post.published_at.iso8601) if post.published_at
      post.tag_list.each do |tag|
        entry.category(:term => tag)
      end
      entry.link(:href => read_url(:id => post), :type => "text/html", :rel => "alternate")
      entry.author do |author|
        author.name(@stream.author)
      end
    end
  end
end