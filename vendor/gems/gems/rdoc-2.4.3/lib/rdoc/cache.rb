require 'thread'
require 'singleton'

##
# A generic, thread-safe in-memory cache. It's used for caching
# RDoc::TemplatePage objects when generating RDoc output.

class RDoc::Cache

  include Singleton

  ##
  # Creates a new, empty cache

  def initialize
    @contents = {}
    @lock = Mutex.new
  end

  ##
  # Checks whether there's a value in the cache with key +key+. If so, then
  # that value will be returned. Otherwise, the given block will be run, and
  # its return value will be put into the cache, and returned.

  def cache(key)
    @lock.synchronize do
      @contents[key] ||= yield
    end
  end

  ##
  # Clears the contents of the cache

  def clear
    @lock.synchronize do
      @contents.clear
    end
  end

end

