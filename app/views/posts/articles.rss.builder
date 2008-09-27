xml.instruct!(:xml, :version => "1.0")
xml.rss('version' => '2.0',
        'xmlns:atom' => 'http://www.w3.org/2005/Atom',
        'xmlns:content' => 'http://purl.org/rss/1.0/modules/content/',
        'xmlns:dc' => 'http://purl.org/dc/elements/1.1/') do |xml|
  xml.channel do |xml|
    xml.title("#{@stream.title} - #{@stream.subtitle}")
    xml.description("#{@stream.subtitle}")
    xml.link(@stream.blog_url)
    xml.tag!('atom:link', :href => File.join(@stream.blog_url.to_s, File.join(request.request_uri.to_s)), :rel => 'self', :type => 'application/rss+xml')
    xml.pubDate(@articles.first.published_at.to_s(:rfc822)) if @articles.first
    xml.generator(APPLICATION_NAME)
    @articles.each do |article|
      xml.item do
        xml.title(h(article.caption))
        xml.description do 
          xml.cdata!(markup(article))
        end
        xml.tag!('content:encoded') do
          xml.cdata!(markup(article))
        end
        xml.tag!('dc:creator', @stream.author)
        xml.pubDate(article.published_at.to_s(:rfc822)) if article.published_at
        xml.link(read_url(:id => article))
        xml.guid(read_url(:id => article), :isPermaLink => true)
        article.tag_list.each do |tag|
          xml.category(tag)
        end
      end
    end
  end
end
