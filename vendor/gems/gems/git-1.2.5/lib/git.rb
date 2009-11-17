
# Add the directory containing this file to the start of the load path if it
# isn't there already.
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'git/base'
require 'git/path'
require 'git/lib'

require 'git/repository'
require 'git/index'
require 'git/working_directory'

require 'git/log'
require 'git/object'

require 'git/branches'
require 'git/branch'
require 'git/remote'

require 'git/diff'
require 'git/status'
require 'git/author'

require 'git/stashes'
require 'git/stash'

lib = Git::Lib.new(nil, nil)
unless lib.meets_required_version?
  $stderr.puts "[WARNING] The git gem requires git #{lib.required_command_version.join('.')} or later, but only found #{lib.current_command_version.join('.')}. You should probably upgrade."
end

# Git/Ruby Library
#
# This provides bindings for working with git in complex
# interactions, including branching and merging, object
# inspection and manipulation, history, patch generation
# and more.  You should be able to do most fundamental git
# operations with this library.
#
# This module provides the basic functions to open a git 
# reference to work with. You can open a working directory,
# open a bare repository, initialize a new repo or clone an
# existing remote repository.
#
# Author::    Scott Chacon (mailto:schacon@gmail.com)
# License::   MIT License
module Git

  VERSION = '1.0.4'
  
  # open a bare repository
  #
  # this takes the path to a bare git repo
  # it expects not to be able to use a working directory
  # so you can't checkout stuff, commit things, etc.
  # but you can do most read operations
  def self.bare(git_dir, options = {})
    Base.bare(git_dir, options)
  end
    
  # open an existing git working directory
  # 
  # this will most likely be the most common way to create
  # a git reference, referring to a working directory.
  # if not provided in the options, the library will assume
  # your git_dir and index are in the default place (.git/, .git/index)
  #
  # options
  #   :repository => '/path/to/alt_git_dir'
  #   :index => '/path/to/alt_index_file'
  def self.open(working_dir, options = {})
    Base.open(working_dir, options)
  end

  # initialize a new git repository, defaults to the current working directory
  #
  # options
  #   :repository => '/path/to/alt_git_dir'
  #   :index => '/path/to/alt_index_file'
  def self.init(working_dir = '.', options = {})
    Base.init(working_dir, options)
  end

  # clones a remote repository
  #
  # options
  #   :bare => true (does a bare clone)
  #   :repository => '/path/to/alt_git_dir'
  #   :index => '/path/to/alt_index_file'
  #
  # example
  #  Git.clone('git://repo.or.cz/rubygit.git', 'clone.git', :bare => true)
  #
  def self.clone(repository, name, options = {})
    Base.clone(repository, name, options)
  end
  
  # Export the current HEAD (or a branch, if <tt>options[:branch]</tt>
  # is specified) into the +name+ directory, then remove all traces of git from the
  # directory.
  #
  # See +clone+ for options.  Does not obey the <tt>:remote</tt> option,
  # since the .git info will be deleted anyway; always uses the default
  # remote, 'origin.'
  def self.export(repository, name, options = {})
    options.delete(:remote)
    repo = clone(repository, name, {:depth => 1}.merge(options))
    repo.checkout("origin/#{options[:branch]}") if options[:branch]
    Dir.chdir(repo.dir.to_s) { FileUtils.rm_r '.git' }
  end

  #g.config('user.name', 'Scott Chacon') # sets value
  #g.config('user.email', 'email@email.com')  # sets value
  #g.config('user.name')  # returns 'Scott Chacon'
  #g.config # returns whole config hash
  def config(name = nil, value = nil)
    lib = Git::Lib.new
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

  # Same as g.config, but forces it to be at the global level
  #
  #g.config('user.name', 'Scott Chacon') # sets value
  #g.config('user.email', 'email@email.com')  # sets value
  #g.config('user.name')  # returns 'Scott Chacon'
  #g.config # returns whole config hash
  def self.global_config(name = nil, value = nil)
    lib = Git::Lib.new(nil, nil)
    if(name && value)
      # set value
      lib.global_config_set(name, value)
    elsif (name)
      # return value
      lib.global_config_get(name)
    else
      # return hash
      lib.global_config_list
    end
  end

  def global_config(name = nil, value = nil)
    self.class.global_config(name, value)
  end
    
end
