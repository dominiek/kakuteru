require RAILS_ROOT + '/test/test_helper'
require 'extract_entities'

class LinguisticsTest < ActiveSupport::TestCase

    def test_tagger_keywords_for_caption
      assert_equal(['sand', 'man'], Linguistics::Tagger.keywords_for_caption('The sand man'))
      assert_equal(['interview', 'harold', 'kumar'], Linguistics::Tagger.keywords_for_caption('An interview with Harold and Kumar.'))
      
      # Dutch
      assert_equal(['doe', 'toch', 'even', 'normaal'], Linguistics::Tagger.keywords_for_caption('Doe toch even normaal'))
    end
  
end


