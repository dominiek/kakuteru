require RAILS_ROOT + '/test/test_helper'
require 'extract_entities'

class HtmlFragmentorTest < ActiveSupport::TestCase

    def setup
      @permanent_fragmentation_tests = {
        'simple_with_navigation'     => ['div', 'id', 'post_1'],
        'kakuteru_article'           => ['div', 'class', 'read page'],
        'wordpress_article'          => ['div', 'class', 'post hentry'],
        'typad_article'              => ['div', 'class', 'content'],
        'twitter_profile'            => ['ul', 'class', 'about vcard entry-author'],
        'kakuteru_index'             => ['div', 'class', 'about'],
        'google_code_statistics'     => ['div', 'class', 'article'],
        'wordpress_custom_article'   => ['div', 'id', 'post-15361'],
        'movable_type_article'       => ['div', 'class', 'asset-more'],
        'movable_type_index'         => ['div', 'id', 'home_posts_block'],
        'confreaks'                  => ['tr', 'id', nil],
      }
    end

    def test_permanent_fragment      
      @permanent_fragmentation_tests.each do |template,assertions|
        fragment = Fragmentors::HTML.new(read_template(template)).permanent_fragment
        element = fragment[:element]
        assert_equal(assertions[0], element.name)
        assert_equal(assertions[2], element.attributes[assertions[1]])
      end
    end
    
    def test_permanent_fragment_text
      assert_match(/^When integrating/, Fragmentors::HTML.new(read_template('simple_with_navigation')).permanent_text)
    end
    
    private
    
    def read_template(name)
      File.open(File.join(RAILS_ROOT, "test/integration/data/#{name}.html")).read
    end
  
end


