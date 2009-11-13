class FSSM::Cache
  module Common
    include Enumerable

    def initialize
      @children = Hash.new
    end

    def each(prefix='./', &block)
      @children.each do |segment, node|
        cprefix = Pathname.for(prefix.dup).join(segment)
        block.call(cprefix, node)
        node.each(cprefix, &block)
      end
    end

    protected
    
    def with_lock
      @mutex.lock
      yield
      @mutex.unlock
    end
    
    def descendant(path)
      recurse_on_key(path, false)
    end

    def descendant!(path)
      recurse_on_key(path, true)
    end

    def child(segment)
      has_child?(segment) ? @children["#{segment}"] : nil
    end

    def child!(segment)
      (@children["#{segment}"] ||= Node.new)
    end

    def has_child?(segment)
      @children.include?("#{segment}")
    end

    def remove_child(segment)
      @children.delete("#{segment}")
    end

    def remove_children
      @children.clear
    end

    def recurse_on_key(key, create)
      key = sanitize_key(key)
      node = self

      until key.empty?
        segment = key.shift
        node = create ? node.child!(segment) : node.child(segment)
        return nil unless node
      end

      node
    end

    def key_for_path(path)
      Pathname.for(path).names
    end

    def relative_path(path)
      sanitize_path(path, false)
    end

    def absolute_path(path)
      sanitize_path(path, true)
    end

    def sanitize_path(path, absolute)
      if path.is_a?(Array)
        first = absolute ? '/' : path.shift
        path = path.inject(Pathname.new("#{first}")) do |pathname, segment|
          pathname.join("#{segment}")
        end
        path
      else
        path = Pathname.for(path)
        absolute ? path.expand_path : path
      end
    end
  end

  class Node
    include Common
    
    attr_accessor :mtime
    attr_accessor :ftype

    def <=>(other)
      self.mtime <=> other.mtime
    end

    def from_path(path)
      path = absolute_path(path)
      @mtime = path.mtime
      @ftype = path.ftype
    end

    protected

    def sanitize_key(key)
      key_for_path(relative_path(key))
    end
  end

  include Common
  
  def initialize
    @mutex = Mutex.new
    super
  end

  def clear
    @mutex.lock
    @children.clear
    @mutex.unlock
  end

  def set(path)
    unset(path)
    node = descendant!(path)
    node.from_path(path)
    node.mtime
  end

  def unset(path='/')    
    key = sanitize_key(path)

    if key.empty?
      self.clear
      return nil
    end
    
    segment = key.pop
    node = descendant(key)

    return unless node
    
    @mutex.lock
    node.remove_child(segment)
    @mutex.unlock    
    
    nil
  end

  def files
    ftype('file')
  end

  def directories
    ftype('directory')
  end

  protected
  
  def each(&block)
    prefix='/'
    super(prefix, &block)
  end

  def ftype(ft)
    inject({}) do |hash, entry|
      path, node = entry
      hash["#{path}"] = node.mtime if node.ftype == ft
      hash
    end
  end
  
  def descendant(path)
    node = recurse_on_key(path, false)
    node
  end

  def descendant!(path)
    @mutex.lock
    node = recurse_on_key(path, true)
    @mutex.unlock
    node
  end

  def sanitize_key(key)
    key_for_path(absolute_path(key))
  end
end
