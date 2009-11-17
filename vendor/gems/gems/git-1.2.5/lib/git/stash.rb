module Git
  class Stash
    
    def initialize(base, message, existing=false)
      @base = base
      @message = message
      save unless existing
    end
    
    def save
      @saved = @base.lib.stash_save(@message)
    end
    
    def saved?
      @saved
    end
    
    def message
      @message
    end
    
    def to_s
      message
    end
    
  end
end