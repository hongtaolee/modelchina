module ReceivedMail
  def from_guest?
    User.find_by_email(self.from.first.downcase) == nil
  end
  
  def from_unauthorized_user?
    User.find_by_email(self.from.first.downcase).sends_email == 0
  end
  
  def author
    if user = User.find_by_email(self.from.first.downcase)
      return user
    else
      name = TMail::Address.parse(self['from'].to_s).phrase
      if name.nil? || name.size < 2
        name = 'unknown'
      end
      email = self.from.first
      return Guest.new(name, email)
    end
  end
  
  def parent
    if self.references.nil? and self.in_reply_to.nil?
      return nil
    end
    
    if self['in-reply-to']
      if self.in_reply_to.first
        parent_messageid = self.in_reply_to.first
      else
        # TMail fails to parse in-reply-to headers where <> is missing,
        # so we do it manually here
        parent_messageid = self['in-reply-to'].phrases.first
      end
    else
      parent_messageid = self.references.reverse.first
    end
    
    parent_messageid = parent_messageid.to_s.tr('<>', '')
    
    if post = Post.find_by_messageid(parent_messageid)
      return post
    else
      if self.cleaned_subject =~ /^Re:/i
        raise 'parent not found'
      else
        # if no parent is found and subject is no reply, treat as new topic
        return nil
      end
    end
  end
  
  def forum
    ((self.to || []) | (self.cc || [])).each do |address|
      if forum = Forum.find_by_list_address(address.downcase)
        return forum
      end
    end
     
    raise "mail for unknown forum received (#{self.to.inspect})"
  end
  
  def create_post
    if Post.find_by_messageid(self.message_id.tr('<>', ''))
      raise 'messageid : has already been taken'
    end
    
    if self.parent
      self.parent.add_reply(self.to_post)
    else
      self.forum.add_post(self.to_post)
    end
  end
  
  def to_post
    post = Post.new
    post.subject = self.cleaned_subject
    post.text = self.cleaned_text
    post.author = self.author
    post.post_method = 'mail'
    post.messageid = self.message_id.tr('<>', '')
    post
  end

  def cleaned_subject
    s = self.subject
    # remove first [tag] from subject
    s.sub!(/\[.+?\] ?/, '')
    s.strip!
    if s.size == 0
      s = '(no subject)'
    end
    s
  end

  def remove_signature(s)
    s = s.dup
    s.gsub!(/\n--(\n.+){0,3}\s*\Z/, '')
    s.gsub!(/\n-- (\n.+){0,6}\s*\Z/, '')
    s.gsub!(/\n-----+(\n.+){0,6}\s*\Z/, '')
    s.gsub!(/\n______+(\n.+){0,6}\s*\Z/, '')
    s
  end

  def cleaned_text
    s = self.plaintext_body
    
    s = remove_signature(s)
    
    # remove TOFU
    s.gsub!(/(\n>.*)+\s*\Z/, '')
    if $1
      # remove "xy wrote:"
      s.gsub!(/\s*\n.*wrote.*:\s*\Z/, '')
    end

    # remove attached "original message"
    s.gsub!(/\s*\n-+Original Message-+.*$/m, '')
    
    # remove too long quoting
    s.gsub!(/^(>.*\n)+?((>+.*\n){10})\s*/, '\3')
    
    s.strip!
    s
  end
  
  def plaintext_body
    if self.multipart?
      # look for multipart/alternative parts
      alternative_parts = self.parts.reject {|p| not p.content_type =~ /^multipart/ }
      interesting_parts = (alternative_parts.first.parts rescue []) + self.parts
      plaintext_parts = interesting_parts.reject {|p| p.content_type != 'text/plain' }
      raise "couln't find a text/plain mime part" if plaintext_parts.empty?
      plaintext_parts.first.body
    else
      raise "body is not text/plain" unless self.content_type = 'text/plain'
      self.body
    end
  end
end
