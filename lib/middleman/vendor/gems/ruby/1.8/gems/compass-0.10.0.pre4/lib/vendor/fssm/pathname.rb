# The bundled ruby pathname library is a slow and hideous beast.
# There. I said it. This version is based on pathname3.

module FSSM
  class Pathname < String

    SEPARATOR = Regexp.quote(File::SEPARATOR)

    if File::ALT_SEPARATOR
      ALT_SEPARATOR = Regexp.quote(File::ALT_SEPARATOR)
      SEPARATOR_PAT = Regexp.compile("[#{SEPARATOR}#{ALT_SEPARATOR}]")
    else
      SEPARATOR_PAT = Regexp.compile(SEPARATOR)
    end

    if RUBY_PLATFORM =~ /(:?mswin|mingw|bccwin)/
      PREFIX_PAT = Regexp.compile("^([A-Za-z]:#{SEPARATOR_PAT})")
    else
      PREFIX_PAT = Regexp.compile("^(#{SEPARATOR_PAT})")
    end

    class << self
      def for(path)
        path = path.is_a?(::FSSM::Pathname) ? path : new(path)
        path.dememo
        path
      end
    end

    def initialize(path)
      if path =~ %r{\0}
        raise ArgumentError, "path cannot contain ASCII NULLs"
      end

      dememo

      super(path)
    end

    def to_path
      self
    end

    def to_s
      "#{self}"
    end

    alias to_str to_s

    def to_a
      return @segments if @segments
      set_prefix_and_names
      @segments = @names.dup
      @segments.delete('.')
      @segments.unshift(@prefix) unless @prefix.empty?
      @segments
    end

    alias segments to_a

    def each_filename(&block)
      to_a.each(&block)
    end

    def ascend
      parts = to_a
      parts.length.downto(1) do |i|
        yield self.class.join(parts[0, i])
      end
    end

    def descend
      parts = to_a
      1.upto(parts.length) do |i|
        yield self.class.join(parts[0, i])
      end
    end

    def root?
      set_prefix_and_names
      @names.empty? && !@prefix.empty?
    end

    def parent
      self + '..'
    end

    def relative?
      set_prefix_and_names
      @prefix.empty?
    end

    def absolute?
      !relative?
    end

    def +(path)
      dup << path
    end

    def <<(path)
      replace(join(path).cleanpath!)
    end

    def cleanpath!
      parts = to_a
      final = []

      parts.each do |part|
        case part
          when '.' then
            next
          when '..' then
            case final.last
              when '..' then
                final.push('..')
              when nil then
                final.push('..')
              else
                final.pop
            end
          else
            final.push(part)
        end
      end

      replace(final.empty? ? Dir.pwd : File.join(*final))
    end

    def cleanpath
      dup.cleanpath!
    end

    def realpath
      raise unless self.exist?

      if File.symlink?(self)
        file = self.dup

        while true
          file = File.join(File.dirname(file), File.readlink(file))
          break unless File.symlink?(file)
        end

        self.class.new(file).clean
      else
        self.class.new(Dir.pwd) + self
      end
    end

    def relative_path_from(base)
      base = self.class.for(base)

      if self.absolute? != base.absolute?
        raise ArgumentError, 'no relative path between a relative and absolute'
      end

      if self.prefix != base.prefix
        raise ArgumentError, "different prefix: #{@prefix.inspect} and #{base.prefix.inspect}"
      end

      base = base.cleanpath!.segments
      dest = dup.cleanpath!.segments

      while !dest.empty? && !base.empty? && dest[0] == base[0]
        base.shift
        dest.shift
      end

      base.shift if base[0] == '.'
      dest.shift if dest[0] == '.'

      if base.include?('..')
        raise ArgumentError, "base directory may not contain '..'"
      end

      path = base.fill('..') + dest
      path = self.class.join(*path)
      path = self.class.new('.') if path.empty?

      path
    end

    def replace(path)
      if path =~ %r{\0}
        raise ArgumentError, "path cannot contain ASCII NULLs"
      end

      dememo

      super(path)
    end

    def unlink
      Dir.unlink(self)
      true
    rescue Errno::ENOTDIR
      File.unlink(self)
      true
    end

    def prefix
      set_prefix_and_names
      @prefix
    end

    def names
      set_prefix_and_names
      @names
    end

    def dememo
      @set = nil
      @segments = nil
      @prefix = nil
      @names = nil
    end

    private

    def set_prefix_and_names
      return if @set

      @names = []

      if (match = PREFIX_PAT.match(self))
        @prefix = match[0].to_s
        @names += match.post_match.split(SEPARATOR_PAT)
      else
        @prefix = ''
        @names += self.split(SEPARATOR_PAT)
      end

      @names.compact!
      @names.delete('')

      @set = true
    end

  end

  class Pathname
    class << self
      def glob(pattern, flags=0)
        dirs = Dir.glob(pattern, flags)
        dirs.map! {|path| new(path)}

        if block_given?
          dirs.each {|dir| yield dir}
          nil
        else
          dirs
        end
      end

      def [](pattern)
        Dir[pattern].map! {|path| new(path)}
      end

      def pwd
        new(Dir.pwd)
      end
    end

    def entries
      Dir.entries(self).map! {|e| FSSM::Pathname.new(e) }
    end

    def mkdir(mode = 0777)
      Dir.mkdir(self, mode)
    end

    def opendir(&blk)
      Dir.open(self, &blk)
    end

    def rmdir
      Dir.rmdir(self)
    end

    def chdir
      blk = lambda { yield self } if block_given?
      Dir.chdir(self, &blk)
    end
  end

  class Pathname
    def blockdev?
      FileTest.blockdev?(self)
    end

    def chardev?
      FileTest.chardev?(self)
    end

    def directory?
      FileTest.directory?(self)
    end

    def executable?
      FileTest.executable?(self)
    end

    def executable_real?
      FileTest.executable_real?(self)
    end

    def exists?
      FileTest.exists?(self)
    end

    def file?
      FileTest.file?(self)
    end

    def grpowned?
      FileTest.grpowned?(self)
    end

    def owned?
      FileTest.owned?(self)
    end

    def pipe?
      FileTest.pipe?(self)
    end

    def readable?
      FileTest.readable?(self)
    end

    def readable_real?
      FileTest.readable_real?(self)
    end

    def setgid?
      FileTest.setgit?(self)
    end

    def setuid?
      FileTest.setuid?(self)
    end

    def socket?
      FileTest.socket?(self)
    end

    def sticky?
      FileTest.sticky?(self)
    end

    def symlink?
      FileTest.symlink?(self)
    end

    def world_readable?
      FileTest.world_readable?(self)
    end

    def world_writable?
      FileTest.world_writable?(self)
    end

    def writable?
      FileTest.writable?(self)
    end

    def writable_real?
      FileTest.writable_real?(self)
    end

    def zero?
      FileTest.zero?(self)
    end

    alias exist? exists?
  end

  class Pathname
    def atime
      File.atime(self)
    end

    def ctime
      File.ctime(self)
    end

    def ftype
      File.ftype(self)
    end

    def lstat
      File.lstat(self)
    end

    def mtime
      File.mtime(self)
    end

    def stat
      File.stat(self)
    end

    def utime(atime, mtime)
      File.utime(self, atime, mtime)
    end
  end

  class Pathname
    class << self
      def join(*parts)
        new(File.join(*parts.reject {|p| p.empty? }))
      end
    end

    def basename
      self.class.new(File.basename(self))
    end

    def chmod(mode)
      File.chmod(mode, self)
    end

    def chown(owner, group)
      File.chown(owner, group, self)
    end

    def dirname
      self.class.new(File.dirname(self))
    end

    def expand_path(from = nil)
      self.class.new(File.expand_path(self, from))
    end

    def extname
      File.extname(self)
    end

    def fnmatch?(pat, flags = 0)
      File.fnmatch(pat, self, flags)
    end

    def join(*parts)
      self.class.join(self, *parts)
    end

    def lchmod(mode)
      File.lchmod(mode, self)
    end

    def lchown(owner, group)
      File.lchown(owner, group, self)
    end

    def link(to)
      File.link(self, to)
    end

    def open(mode = 'r', perm = nil, &blk)
      File.open(self, mode, perm, &blk)
    end

    def readlink
      self.class.new(File.readlink(self))
    end

    def rename(to)
      File.rename(self, to)
      replace(to)
    end

    def size
      File.size(self)
    end

    def size?
      File.size?(self)
    end

    def symlink(to)
      File.symlink(self, to)
    end

    def truncate
      File.truncate(self)
    end
  end

  class Pathname
    def mkpath
      self.class.new(FileUtils.mkpath(self))
    end

    def rmtree
      self.class.new(FileUtils.rmtree(self).first)
    end

    def touch
      self.class.new(FileUtils.touch(self).first)
    end
  end

  class Pathname
    def each_line(sep = $/, &blk)
      IO.foreach(self, sep, &blk)
    end

    def read(len = nil, off = 0)
      IO.read(self, len, off)
    end

    def readlines(sep = $/)
      IO.readlines(self, sep)
    end

    def sysopen(mode = 'r', perm = nil)
      IO.sysopen(self, mode, perm)
    end
  end

  class Pathname
    def find
      Find.find(self) {|path| yield FSSM::Pathname.new(path) }
    end
  end

end
