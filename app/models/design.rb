class Design < ActiveRecord::Base
  belongs_to :stream
  
  DEFAULT_LAYOUT = <<-HTML
  
    $articles
    $media

    <div class="stream_and_context">
      $activity
    
      $tagcloud
      $profiles
      $trips
      $stats

      $pagination
    </div>
    
  HTML
  VALID_SECTIONS = ['articles', 'media', 'activity', 'tagcloud', 'profiles', 'trips', 'stats', 'pagination']
  
  def layout
    html = super
    html.blank? ? Design::DEFAULT_LAYOUT.dup : html
  end

end
