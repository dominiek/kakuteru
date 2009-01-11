xml.instruct!(:xml, :version => "1.0")
xml.rss('version' => '2.0',
        'xmlns:atom' => 'http://www.w3.org/2005/Atom',
        'xmlns:content' => 'http://purl.org/rss/1.0/modules/content/',
        'xmlns:dc' => 'http://purl.org/dc/elements/1.1/') do |xml|
  xml.channel do |xml|
    xml.title(@title)
    xml.description("#{@stream.subtitle}")
    xml.link("http://#{request.host_with_port}/")
    xml.tag!('atom:link', :href => "http://#{request.host_with_port}#{request.request_uri}", :rel => 'self', :type => 'application/rss+xml')
    xml.pubDate(@posts.first.published_at.to_s(:rfc822)) if @posts.first
    xml.generator(APPLICATION_NAME)
    @posts.each do |post|
      xml.item do
        xml.title(h(post.caption))
        post_body = render(:partial => "posts/#{post.type}.html.erb", :locals => {:post => post})
        xml.description do 
          xml.cdata!(post_body)
        end
        xml.tag!('content:encoded') do
          xml.cdata!(post_body)
        end
        xml.tag!('dc:creator', @stream.author)
        xml.pubDate(post.published_at.to_s(:rfc822)) if post.published_at
        xml.link(read_url(:id => post))
        xml.guid(read_url(:id => post), :isPermaLink => true)
        post.tag_list.each do |tag|
          xml.category(tag)
        end
      end
    end
  end
end
