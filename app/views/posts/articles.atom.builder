xml.instruct!(:xml, :version => "1.0")
xml.feed(:xmlns => "http://www.w3.org/2005/Atom") do |feed|
  feed.title("#{@stream.title} - #{@stream.subtitle}")
  feed.id("tag:#{request.host},#{Time.now.year}:#{APPLICATION_NAME}")
  feed.link(:href => @stream.blog_url, :rel => "alternate", :type => "text/html")
  feed.link(:href => File.join(@stream.blog_url, File.join(request.request_uri), :rel => "self", :type => "application/atom+xml")
  feed.updated(@articles.first.published_at.iso8601) if @articles.first
  feed.generator(APPLICATION_NAME, :uri => 'http://dominiek.com/tag/maitako')
  @articles.each do |article|
    feed.entry do |entry|
      entry.id("tag:#{request.host},#{Time.now.strftime("%Y-%m-%d")}:#{APPLICATION_NAME}")
      entry.title(h(article.caption))
      entry.content(:type => 'html') do
        entry.cdata!(markup(article))
      end
      entry.updated(article.published_at.iso8601) if article.published_at
      article.tag_list.each do |tag|
        entry.category(:term => tag)
      end
      entry.link(:href => read_url(:id => article), :type => "text/html", :rel => "alternate")
      entry.author do |author|
        author.name(@stream.author)
      end
    end
  end
end