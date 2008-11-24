require RAILS_ROOT + '/test/test_helper'

class PostTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_caption_tagging
    post = Post.create(:caption => "Kakuteru, Semantic lifestreaming on Rails")
    assert_equal(['kakuteru', 'semantic', 'lifestreaming', 'rails'], post.tag_list)
    post.update_attribute(:caption, 'Kakuteru Pornography')
    assert_equal(['kakuteru', 'semantic', 'lifestreaming', 'rails', 'pornography'], post.tag_list)
    
  end
end
