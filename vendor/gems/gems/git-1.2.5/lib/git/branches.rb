module Git
  
  # object that holds all the available branches
  class Branches
    include Enumerable
    
    def initialize(base)
      @branches = {}
      
      @base = base
            
      @base.lib.branches_all.each do |b|
        @branches[b[0]] = Git::Branch.new(@base, b[0])
      end
    end

    def local
      self.select { |b| !b.remote }
    end
    
    def remote
      self.select { |b| b.remote }
    end
    
    # array like methods

    def size
      @branches.size
    end    
    
    def each(&block)
      @branches.values.each(&block)
    end
    
    def [](symbol)
      @branches[symbol.to_s]
    end
    
    def to_s
      out = ''
      @branches.each do |k, b|
        out << (b.current ? '* ' : '  ') << b.to_s << "\n"
      end
      out
    end
    
  end
end
