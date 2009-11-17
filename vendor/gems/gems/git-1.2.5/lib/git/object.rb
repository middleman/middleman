module Git
  
  class GitTagNameDoesNotExist< StandardError 
  end
  
  # represents a git object
  class Object
    
    class AbstractObject
      attr_accessor :objectish, :size, :type, :mode
      
      def initialize(base, objectish)
        @base = base
        @objectish = objectish.to_s
        @contents = nil
        @trees = nil
        @size = nil
        @sha = nil
      end

      def sha
        @sha ||= @base.lib.revparse(@objectish)
      end
      
      def size
        @size ||= @base.lib.object_size(@objectish)
      end
      
      # Get the object's contents.
      # If no block is given, the contents are cached in memory and returned as a string.
      # If a block is given, it yields an IO object (via IO::popen) which could be used to
      # read a large file in chunks.
      #
      # Use this for large files so that they are not held in memory.
      def contents(&block)
        if block_given?
          @base.lib.object_contents(@objectish, &block)
        else
          @contents ||= @base.lib.object_contents(@objectish)
        end
      end
      
      def contents_array
        self.contents.split("\n")
      end
      
      def to_s
        @objectish
      end
      
      def grep(string, path_limiter = nil, opts = {})
        opts = {:object => sha, :path_limiter => path_limiter}.merge(opts)
        @base.lib.grep(string, opts)
      end
      
      def diff(objectish)
        Git::Diff.new(@base, @objectish, objectish)
      end
      
      def log(count = 30)
        Git::Log.new(@base, count).object(@objectish)
      end
      
      # creates an archive of this object (tree)
      def archive(file = nil, opts = {})
        @base.lib.archive(@objectish, file, opts)
      end
      
      def tree?; false; end
      
      def blob?; false; end
      
      def commit?; false; end

      def tag?; false; end
     
    end
  
    
    class Blob < AbstractObject
      
      def initialize(base, sha, mode = nil)
        super(base, sha)
        @mode = mode
      end
      
      def blob?
        true
      end

    end
  
    class Tree < AbstractObject
      
      @trees = nil
      @blobs = nil
      
      def initialize(base, sha, mode = nil)
        super(base, sha)
        @mode = mode
      end
            
      def children
        blobs.merge(subtrees)
      end
      
      def blobs
        check_tree
        @blobs
      end
      alias_method :files, :blobs
      
      def trees
        check_tree
        @trees
      end
      alias_method :subtrees, :trees
      alias_method :subdirectories, :trees
       
      def full_tree
        @base.lib.full_tree(@objectish)
      end
                  
      def depth
        @base.lib.tree_depth(@objectish)
      end
      
      def tree?
        true
      end
       
      private

        # actually run the git command
        def check_tree
          unless @trees
            @trees = {}
            @blobs = {}
            data = @base.lib.ls_tree(@objectish)
            data['tree'].each { |k, d| @trees[k] = Git::Object::Tree.new(@base, d[:sha], d[:mode]) }
            data['blob'].each { |k, d| @blobs[k] = Git::Object::Blob.new(@base, d[:sha], d[:mode]) }
          end
        end
      
    end
  
    class Commit < AbstractObject
      
      def initialize(base, sha, init = nil)
        super(base, sha)
        @tree = nil
        @parents = nil
        @author = nil
        @committer = nil
        @message = nil
        if init
          set_commit(init)
        end
      end
      
      def message
        check_commit
        @message
      end
      
      def name
        @base.lib.namerev(sha)
      end
      
      def gtree
        check_commit
        Tree.new(@base, @tree)
      end
      
      def parent
        parents.first
      end
      
      # array of all parent commits
      def parents
        check_commit
        @parents        
      end
      
      # git author
      def author     
        check_commit
        @author
      end
      
      def author_date
        author.date
      end
      
      # git author
      def committer
        check_commit
        @committer
      end
      
      def committer_date 
        committer.date
      end
      alias_method :date, :committer_date

      def diff_parent
        diff(parent)
      end
      
      def set_commit(data)
        if data['sha']
          @sha = data['sha']
        end
        @committer = Git::Author.new(data['committer'])
        @author = Git::Author.new(data['author'])
        @tree = Git::Object::Tree.new(@base, data['tree'])
        @parents = data['parent'].map{ |sha| Git::Object::Commit.new(@base, sha) }
        @message = data['message'].chomp
      end
      
      def commit?
        true
      end

      private
  
        # see if this object has been initialized and do so if not
        def check_commit
          unless @tree
            data = @base.lib.commit_data(@objectish)
            set_commit(data)
          end
        end
      
    end
  
    class Tag < AbstractObject
      attr_accessor :name
      
      def initialize(base, sha, name)
        super(base, sha)
        @name = name
      end

      def tag?
        true
      end
        
    end
    
    # if we're calling this, we don't know what type it is yet
    # so this is our little factory method
    def self.new(base, objectish, type = nil, is_tag = false)
      if is_tag
        sha = base.lib.tag_sha(objectish)
        if sha == ''
          raise Git::GitTagNameDoesNotExist.new(objectish)
        end
        return Git::Object::Tag.new(base, sha, objectish)
      end
      
      type ||= base.lib.object_type(objectish)
      klass =
        case type
        when /blob/   then Blob   
        when /commit/ then Commit
        when /tree/   then Tree
        end
      klass.new(base, objectish)
    end
    
  end
end
