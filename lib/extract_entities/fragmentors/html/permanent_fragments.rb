
##
# Permanent fragements are things like: title, about, author, content of an article etc
module PermanentFragments
    
  def permanent_text
    fragment = self.permanent_fragment
    fragment ? fragment[:element].inner_text.strip! : nil
  end
  
  # Based on the title, find a common chunk of HTML that is the most relevant
  # This is to extract atomic/permanent content
  def permanent_fragment(options = {})
    fragments = self.permanent_fragments(options)
        
    return nil if fragments.blank?
    
    if fragments.size == 1
      return fragments.first
    end

    # Find common ancestors
    fragments_by_parents = {}
    fragments.each do |fragment|
      next unless fragment[:parent]
      fragments_by_parents[fragment[:parent]] ||= []
      fragments_by_parents[fragment[:parent]] << fragment
    end
    
    # Find the top parent
    top_fragments = []
    top_parent_fragments_count = 0
    fragments_by_parents.each do |parent,fr|
      if fr.size > top_parent_fragments_count
        top_parent_fragments_count = fr.size
        top_fragments = fr
      end
    end
    
    # Failed?
    if top_fragments.blank?
      return fragments.first
    end
    
    # Create a combined fragment with combined score
    element = top_fragments.first[:element]
    combined_fragment = {:score => 0, :element => element.parent, :inner_text => element.parent.inner_text, :parent => element.parent ? element.parent.object_id : nil}
    top_fragments.each { |f| combined_fragment[:score] = combined_fragment[:score] + f[:score] }

    # De-value the body tag
    if combined_fragment[:element].name == 'body'
      combined_fragment[:score] = top_fragments.size
    end
    
    # Add combined fragment to pool and re-order by score.
    fragments << combined_fragment
    fragments.sort! { |b,a| a[:score] <=> b[:score] }
    
    #puts fragments.collect { |f| ["#{f[:element].parent ? f[:element].parent.name : nil}:#{f[:parent]}", f[:element].name + '(' + f[:score].to_s + '): ', f[:element].attributes] }.inspect
    
    fragments.first
  end
  
  # Get all relevant div/span/td/body/p blocks from the HTML page - based on the <title>
  # This is to extract atomic/permanent content
  def permanent_fragments(options = {})
    title_elements = (@doc/"title")
    return html if title_elements.blank?
    title_inner_text = title_elements.first.inner_text
    keywords = Linguistics::Tagger.keywords_for_caption(title_inner_text)
    blocks = []
    
    # First, find the smallest blocks, but bigger than the title
    (@doc/"div|span|td|body|p|dd|ul").each do |element|
      
      next if element_with_negative_identifier(element)
      
      inner_text = ''
      element.children.each do |child|
        inner_text << child.to_s if child.is_a?(Hpricot::Text)
      end
      inner_text.downcase!
      next if inner_text.size <= title_inner_text.size
      
      # Check the occurance of keyword in block, skip if none
      num_matches = 0
      keywords.each { |k| num_matches+=1 if inner_text.split(/\s+/).include?(k) }
      next if num_matches == 0
      
      # Calculate a score based on keyword matches times positive naming of id/class
      score = num_matches
      identifier = nil
      if (identifier = element_with_positive_identifier(element))
        score = score * 2;
      end
      
      blocks << {:score => score, :element => element, :inner_text => inner_text, :parent => element.parent ? element.parent.object_id : nil, :identifier => identifier}
    end
    
    big_block_identifiers = {}
    
    # Finding big blocks with both matches and positive identifiers
    (@doc/"div|span|table|td|body|p|dd|ul").each do |element|
      
      next if element_with_negative_identifier(element)
      
      # Need to log identifier statistics
      identifier = nil
      if (identifier = element_with_positive_identifier(element))
        big_block_identifiers[identifier] ||= 0
        big_block_identifiers[identifier] += 1
      else
        next
      end
      
      inner_text = element.inner_text
      inner_text.downcase!
      next if inner_text.size <= title_inner_text.size
      
      # Check the occurance of keyword in block, skip if none
      num_matches = 0
      keywords.each { |k| num_matches+=1 if inner_text.split(/\s+/).include?(k) }
      
      #puts "#{element.name}(#{element.inner_text.size}/#{title_inner_text.size}, score:#{num_matches} * #{element_with_positive_identifier(element)}): " + element.attributes['class'].to_s
      
      next if num_matches == 0
      
      # Calculate a score based on keyword matches times positive naming of id/class
      score = num_matches
      if identifier
        score = score * 3;
      end
      
      blocks << {:score => score, :element => element, :inner_text => inner_text, :parent => element.parent ? element.parent : nil, :identifier => identifier}
    end
    
    # De-value the identifiers that are repeated
    blocks.each do |block|
      if block[:identifier] && big_block_identifiers[block[:identifier]].to_i > 1
        block[:score] = block[:score] / 3;
      end
    end
    
    # Order those blocks by top matches
    blocks.sort! { |b,a| a[:score] <=> b[:score] }
    blocks.reject! { |b| b[:score] == 0 }
    blocks
  end
  
  private

  def element_with_positive_identifier(element)
    identifiers_for_element(element).each do |identifier|
      return identifier if POSITIVE_IDENTIFIERS.include?(identifier)
    end
    return false
  end
  
  def element_with_negative_identifier(element)
    identifiers_for_element(element).each do |identifier|
      return identifier if NEGATIVE_IDENTIFIERS.include?(identifier)
    end
    return false
  end
  
  def identifiers_for_element(element)
    identifiers = []
    identifiers << element.attributes['id'] if element.attributes['id']
    if element.attributes['class']
      klasses = element.attributes['class']
      klasses.split(/\s+/).each { |k| identifiers << k }
    end
    identifiers
  end
  
  # From: http://westciv.typepad.com/dog_or_higher/2005/11/real_world_sema.html
  # Thanks go out to http://twitter.com/kimtaro
  
  POSITIVE_IDENTIFIERS = [
    'about',
    'entry',
    'description',
    'bodytext',
    'post',
    'author',
    'caption',
    'read',
    'summary',
    'maintext',
    'entry-body',
    'entry-content',
    'entry-author',
    'vcard',
    'article'
  ]
  
  NEGATIVE_IDENTIFIERS = [
    'navigation',
    'help',
    'noMargin',
    'prefill',
    'button',
    'Menu',
    'searchFormSection',
    'rightAnchor',
    'seeAllLink',
    'seeAllBullet',
    'adSpacer',
    'nav',
    'ocDCP',
    'Date',
    'CIPpromo',
    'small',
    'copyright',
    'tiny',
    'link',
    'search',
    'links',
    'topMenu',
    'left',
    'more',
    'smalltext',
    'prnav',
    'prred',
    'logo',
    'spacer',
    'MsoNormal',
    'searchbox',
    'leftnav',
    'inputbox',
    'topnav',
    'back',
    'searchinput',
    'border',
    'side',
    'selected',
    'icons',
    'helpblk',
    'ebcPic',
    'ebPicture',
    'visual',
    'topmenu-spacer',
    'submenu',
    'input',
    'navbar',
    'calendar',
    'formbut',
    'breadcrumb',
    'navlinks',
    'nwslink',
    'leftmenu',
    'rub1',
    'cbox',
    'ta-c',
    'formtext',
    'mainmenu',
    'cal',
    'searchtext',
    'sidebar',
    'powered',
    'imagealign',
    'ckCol',
    'binImg',
    'tm',
    'searchform',
    'separator',
    'btn',
    'menu2',
    'foot_alt',
    'bannerAd',
    'tabs',
    'icomtb',
    'ContentBorder',
    'timestamp',
    'TextAd',
    'Label',
    'banner',
    'navtext',
    'udm',
    'pagenav',
    'style6',
    'bottomnav',
    'alt',
    'nav3',
    'bot',
    'narrowcolumn',
    'clickPath',
    'formbutt',
    'lnav',
    'navcolor',
    'navMainSections',
    'sidebarad',
    'cattitle',
    'ens',
    'fivevert',
    'disclaimer',
    'disclaimerlink'
  ]
  
end
