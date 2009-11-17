module Git
  class Remote < Path
    
    attr_accessor :name, :url, :fetch_opts
    
    def initialize(base, name)
      @base = base
      config = @base.lib.config_remote(name)
      @name = name
      @url = config['url']
      @fetch_opts = config['fetch']
    end
    
    def remove
      @base.remote_remove(@name)
    end
    
    def fetch
      @base.fetch(@name)
    end
    
    # merge this remote locally
    def merge(branch = 'master')
      @base.merge("#{@name}/#{branch}")
    end
    
    def branch(branch = 'master')
      Git::Branch.new(@base, "#{@name}/#{branch}")
    end
    
    def remove
      @base.lib.remote_remove(@name)     
    end
    
    def to_s
      @name
    end
    
  end
end
