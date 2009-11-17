module Git
  class Author
    attr_accessor :name, :email, :date
    
    def initialize(author_string)
      if m = /(.*?) <(.*?)> (\d+) (.*)/.match(author_string)
        @name = m[1]
        @email = m[2]
        @date = Time.at(m[3].to_i)
      end
    end
    
  end
end