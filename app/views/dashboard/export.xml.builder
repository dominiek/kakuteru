xml.instruct!
xml.posts do
  @stream.posts.find(:all, :include => [:service, :medias, :links]).each do |post|
    xml << post.to_xml
  end
end