module Git
  
  class Base

    # opens a bare Git Repository - no working directory options
    def self.bare(git_dir, opts = {})
      self.new({:repository => git_dir}.merge(opts))
    end
    
    # opens a new Git Project from a working directory
    # you can specify non-standard git_dir and index file in the options
    def self.open(working_dir, opts={})
      self.new({:working_directory => working_dir}.merge(opts))
    end

    # initializes a git repository
    #
    # options:
    #  :repository
    #  :index_file
    #
    def self.init(working_dir, opts = {})
      opts = {
        :working_directory => working_dir,
        :repository => File.join(working_dir, '.git')
      }.merge(opts)
      
      FileUtils.mkdir_p(opts[:working_directory]) if opts[:working_directory] && !File.directory?(opts[:working_directory])
      
      # run git_init there
      Git::Lib.new(opts).init
       
      self.new(opts)
    end

    # clones a git repository locally
    #
    #  repository - http://repo.or.cz/w/sinatra.git
    #  name - sinatra
    #
    # options:
    #   :repository
    #
    #    :bare
    #   or 
    #    :working_directory
    #    :index_file
    #
    def self.clone(repository, name, opts = {})
      # run git-clone 
      self.new(Git::Lib.new.clone(repository, name, opts))
    end
        
    def initialize(options = {})
      if working_dir = options[:working_directory]
        options[:repository] ||= File.join(working_dir, '.git')
        options[:index] ||= File.join(working_dir, '.git', 'index')
      end
      if options[:log]
        @logger = options[:log]
        @logger.info("Starting Git")
      else
        @logger = nil
      end
     
      @working_directory = options[:working_directory] ? Git::WorkingDirectory.new(options[:working_directory]) : nil
      @repository = options[:repository] ? Git::Repository.new(options[:repository]) : nil 
      @index = options[:index] ? Git::Index.new(options[:index], false) : nil
    end
  
  
    # returns a reference to the working directory
    #  @git.dir.path
    #  @git.dir.writeable?
    def dir
      @working_directory
    end

    # returns reference to the git repository directory
    #  @git.dir.path
    def repo
      @repository
    end
    
    # returns reference to the git index file
    def index
      @index
    end
    
    
    def set_working(work_dir, check = true)
      @lib = nil
      @working_directory = Git::WorkingDirectory.new(work_dir.to_s, check)
    end

    def set_index(index_file, check = true)
      @lib = nil
      @index = Git::Index.new(index_file.to_s, check)
    end
    
    # changes current working directory for a block
    # to the git working directory
    #
    # example
    #  @git.chdir do 
    #    # write files
    #    @git.add
    #    @git.commit('message')
    #  end
    def chdir # :yields: the Git::Path
      Dir.chdir(dir.path) do
        yield dir.path
      end
    end
    
    # returns the repository size in bytes
    def repo_size
      size = 0
      Dir.chdir(repo.path) do
        (size, dot) = `du -s`.chomp.split
      end
      size.to_i
    end
    
    #g.config('user.name', 'Scott Chacon') # sets value
    #g.config('user.email', 'email@email.com')  # sets value
    #g.config('user.name')  # returns 'Scott Chacon'
    #g.config # returns whole config hash
    def config(name = nil, value = nil)
      if(name && value)
        # set value
        lib.config_set(name, value)
      elsif (name)
        # return value
        lib.config_get(name)
      else
        # return hash
        lib.config_list
      end
    end
    
    # factory methods
    
    # returns a Git::Object of the appropriate type
    # you can also call @git.gtree('tree'), but that's 
    # just for readability.  If you call @git.gtree('HEAD') it will
    # still return a Git::Object::Commit object.  
    #
    # @git.object calls a factory method that will run a rev-parse 
    # on the objectish and determine the type of the object and return 
    # an appropriate object for that type 
    def object(objectish)
      Git::Object.new(self, objectish)
    end
    
    def gtree(objectish)
      Git::Object.new(self, objectish, 'tree')
    end
    
    def gcommit(objectish)
      Git::Object.new(self, objectish, 'commit')
    end
    
    def gblob(objectish)
      Git::Object.new(self, objectish, 'blob')
    end
    
    # returns a Git::Log object with count commits
    def log(count = 30)
      Git::Log.new(self, count)
    end

    # returns a Git::Status object
    def status
      Git::Status.new(self)
    end
        
    # returns a Git::Branches object of all the Git::Branch objects for this repo
    def branches
      Git::Branches.new(self)
    end
    
    # returns a Git::Branch object for branch_name
    def branch(branch_name = 'master')
      Git::Branch.new(self, branch_name)
    end
    
    # returns +true+ if the branch exists locally
    def is_local_branch?(branch)
      branch_names = self.branches.local.map {|b| b.name}
      branch_names.include?(branch)
    end

    # returns +true+ if the branch exists remotely
    def is_remote_branch?(branch)
      branch_names = self.branches.local.map {|b| b.name}
      branch_names.include?(branch)
    end

    # returns +true+ if the branch exists
    def is_branch?(branch)
      branch_names = self.branches.map {|b| b.name}
      branch_names.include?(branch)
    end

    # returns a Git::Remote object
    def remote(remote_name = 'origin')
      Git::Remote.new(self, remote_name)
    end

    # this is a convenience method for accessing the class that wraps all the 
    # actual 'git' forked system calls.  At some point I hope to replace the Git::Lib
    # class with one that uses native methods or libgit C bindings
    def lib
      @lib ||= Git::Lib.new(self, @logger)
    end
    
    # will run a grep for 'string' on the HEAD of the git repository
    # 
    # to be more surgical in your grep, you can call grep() off a specific
    # git object.  for example:
    #
    #  @git.object("v2.3").grep('TODO')
    #
    # in any case, it returns a hash of arrays of the type:
    #  hsh[tree-ish] = [[line_no, match], [line_no, match2]]
    #  hsh[tree-ish] = [[line_no, match], [line_no, match2]]
    #
    # so you might use it like this:
    #
    #   @git.grep("TODO").each do |sha, arr|
    #     puts "in blob #{sha}:"
    #     arr.each do |match|
    #       puts "\t line #{match[0]}: '#{match[1]}'"
    #     end
    #   end
    def grep(string, path_limiter = nil, opts = {})
      self.object('HEAD').grep(string, path_limiter, opts)
    end
    
    # returns a Git::Diff object
    def diff(objectish = 'HEAD', obj2 = nil)
      Git::Diff.new(self, objectish, obj2)
    end
    
    # adds files from the working directory to the git repository
    def add(path = '.')
      self.lib.add(path)
    end

    # removes file(s) from the git repository
    def remove(path = '.', opts = {})
      self.lib.remove(path, opts)
    end

    # resets the working directory to the provided commitish
    def reset(commitish = nil, opts = {})
      self.lib.reset(commitish, opts)
    end

    # resets the working directory to the commitish with '--hard'
    def reset_hard(commitish = nil, opts = {})
      opts = {:hard => true}.merge(opts)
      self.lib.reset(commitish, opts)
    end

    # commits all pending changes in the index file to the git repository
    # 
    # options:
    #   :add_all
    #   :allow_empty
    #   :author
    def commit(message, opts = {})
      self.lib.commit(message, opts)
    end
        
    # commits all pending changes in the index file to the git repository,
    # but automatically adds all modified files without having to explicitly
    # calling @git.add() on them.  
    def commit_all(message, opts = {})
      opts = {:add_all => true}.merge(opts)
      self.lib.commit(message, opts)
    end

    # checks out a branch as the new git working directory
    def checkout(branch = 'master', opts = {})
      self.lib.checkout(branch, opts)
    end
    
    # checks out an old version of a file
    def checkout_file(version, file)
      self.lib.checkout_file(version,file)
    end

    # fetches changes from a remote branch - this does not modify the working directory,
    # it just gets the changes from the remote if there are any
    def fetch(remote = 'origin')
      self.lib.fetch(remote)
    end

    # pushes changes to a remote repository - easiest if this is a cloned repository,
    # otherwise you may have to run something like this first to setup the push parameters:
    #
    #  @git.config('remote.remote-name.push', 'refs/heads/master:refs/heads/master')
    #
    def push(remote = 'origin', branch = 'master', tags = false)
      self.lib.push(remote, branch, tags)
    end
    
    # merges one or more branches into the current working branch
    #
    # you can specify more than one branch to merge by passing an array of branches
    def merge(branch, message = 'merge')
      self.lib.merge(branch, message)
    end

    # iterates over the files which are unmerged
    def each_conflict(&block) # :yields: file, your_version, their_version
      self.lib.conflicts(&block)
    end

    # fetches a branch from a remote and merges it into the current working branch
    def pull(remote = 'origin', branch = 'master', message = 'origin pull')
      fetch(remote)
      merge(branch, message)
    end
    
    # returns an array of Git:Remote objects
    def remotes
      self.lib.remotes.map { |r| Git::Remote.new(self, r) }
    end

    # adds a new remote to this repository
    # url can be a git url or a Git::Base object if it's a local reference
    # 
    #  @git.add_remote('scotts_git', 'git://repo.or.cz/rubygit.git')
    #  @git.fetch('scotts_git')
    #  @git.merge('scotts_git/master')
    #
    def add_remote(name, url, opts = {})
      url = url.repo.path if url.is_a?(Git::Base)
      self.lib.remote_add(name, url, opts)
      Git::Remote.new(self, name)
    end

    # returns an array of all Git::Tag objects for this repository
    def tags
      self.lib.tags.map { |r| tag(r) }
    end
    
    # returns a Git::Tag object
    def tag(tag_name)
      Git::Object.new(self, tag_name, 'tag', true)
    end

    # creates a new git tag (Git::Tag)
    def add_tag(tag_name)
      self.lib.tag(tag_name)
      tag(tag_name)
    end
    
    # creates an archive file of the given tree-ish
    def archive(treeish, file = nil, opts = {})
      self.object(treeish).archive(file, opts)
    end
    
    # repacks the repository
    def repack
      self.lib.repack
    end
    
    def gc
      self.lib.gc
    end
    
    def apply(file)
      if File.exists?(file)
        self.lib.apply(file)
      end
    end
    
    def apply_mail(file)
      self.lib.apply_mail(file) if File.exists?(file)
    end
    
    ## LOWER LEVEL INDEX OPERATIONS ##
    
    def with_index(new_index) # :yields: new_index
      old_index = @index
      set_index(new_index, false)
      return_value = yield @index
      set_index(old_index)
      return_value
    end
    
    def with_temp_index &blk
      tempfile = Tempfile.new('temp-index')
      temp_path = tempfile.path
      tempfile.unlink
      with_index(temp_path, &blk)
    end
    
    def checkout_index(opts = {})
      self.lib.checkout_index(opts)
    end
    
    def read_tree(treeish, opts = {})
      self.lib.read_tree(treeish, opts)
    end
    
    def write_tree
      self.lib.write_tree
    end
    
    def commit_tree(tree = nil, opts = {})
      Git::Object::Commit.new(self, self.lib.commit_tree(tree, opts))
    end
    
    def write_and_commit_tree(opts = {})
      tree = write_tree
      commit_tree(tree, opts)
    end
      
    def update_ref(branch, commit)
      branch(branch).update_ref(commit)
    end
    
    
    def ls_files(location=nil)
      self.lib.ls_files(location)
    end

    def with_working(work_dir) # :yields: the Git::WorkingDirectory
      return_value = false
      old_working = @working_directory
      set_working(work_dir) 
      Dir.chdir work_dir do
        return_value = yield @working_directory
      end
      set_working(old_working)
      return_value
    end
    
    def with_temp_working &blk
      tempfile = Tempfile.new("temp-workdir")
      temp_dir = tempfile.path
      tempfile.unlink
      Dir.mkdir(temp_dir, 0700)
      with_working(temp_dir, &blk)
    end
    
    
    # runs git rev-parse to convert the objectish to a full sha
    #
    #   @git.revparse("HEAD^^")
    #   @git.revparse('v2.4^{tree}')
    #   @git.revparse('v2.4:/doc/index.html')
    #
    def revparse(objectish)
      self.lib.revparse(objectish)
    end
    
    def ls_tree(objectish)
      self.lib.ls_tree(objectish)
    end
    
    def cat_file(objectish)
      self.lib.object_contents(objectish)
    end

    # returns the name of the branch the working directory is currently on
    def current_branch
      self.lib.branch_current
    end

    
  end
  
end
