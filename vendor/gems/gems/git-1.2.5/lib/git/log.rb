module Git
  
  # object that holds the last X commits on given branch
  class Log
    include Enumerable
    
    def initialize(base, count = 30)
      dirty_log
      @base = base
      @count = count
 
      @commits = nil
      @author = nil
      @grep = nil
      @object = nil
      @path = nil
      @since = nil
      @skip = nil
      @until = nil
      @between = nil
    end

    def object(objectish)
      dirty_log
      @object = objectish
      return self
    end

    def author(regex)
      dirty_log
      @author = regex
      return self
    end
        
    def grep(regex)
      dirty_log
      @grep = regex
      return self
    end
    
    def path(path)
      dirty_log
      @path = path
      return self
    end
    
    def skip(num)
      dirty_log
      @skip = num
      return self
    end
    
    def since(date)
      dirty_log
      @since = date
      return self
    end
    
    def until(date)
      dirty_log
      @until = date
      return self
    end
    
    def between(sha1, sha2 = nil)
      dirty_log
      @between = [sha1, sha2]
      return self
    end
    
    def to_s
      self.map { |c| c.to_s }.join("\n")
    end
    

    # forces git log to run
    
    def size
      check_log
      @commits.size rescue nil
    end
    
    def each(&block)
      check_log
      @commits.each(&block)
    end
    
    def first
      check_log
      @commits.first rescue nil
    end
    
    private 
    
      def dirty_log
        @dirty_flag = true
      end
      
      def check_log
        if @dirty_flag
          run_log
          @dirty_flag = false
        end
      end
      
      # actually run the 'git log' command
      def run_log      
        log = @base.lib.full_log_commits(:count => @count, :object => @object, 
                                    :path_limiter => @path, :since => @since, 
                                    :author => @author, :grep => @grep, :skip => @skip,
                                    :until => @until, :between => @between)
        @commits = log.map { |c| Git::Object::Commit.new(@base, c['sha'], c) }
      end
      
  end
  
end
