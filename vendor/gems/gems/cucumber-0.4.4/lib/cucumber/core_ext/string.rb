class String #:nodoc:
  def indent(n)
    if n >= 0
      gsub(/^/, ' ' * n)
    else
      gsub(/^ {0,#{-n}}/, "")
    end
  end
  
  if (Cucumber::JRUBY && Cucumber::RAILS) || Cucumber::RUBY_1_9
    # Workaround for http://tinyurl.com/55uu3u 
    alias jlength length
  else
    require 'jcode'
  end
end
