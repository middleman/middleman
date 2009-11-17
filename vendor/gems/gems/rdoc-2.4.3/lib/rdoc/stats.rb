require 'rdoc'
require 'thread'

##
# Simple stats collector

class RDoc::Stats

  attr_reader :num_classes
  attr_reader :num_files
  attr_reader :num_methods
  attr_reader :num_modules
  attr_reader :total_files

  def initialize(total_files, verbosity = 1)
    @lock = Mutex.new
    
    @num_classes = 0
    @num_files   = 0
    @num_methods = 0
    @num_modules = 0
    @total_files = total_files

    @start = Time.now

    @display = case verbosity
               when 0 then Quiet.new
               when 1 then Normal.new(total_files)
               else        Verbose.new
               end
  end
  
  def begin_adding(number_of_workers)
    @display.begin_adding(number_of_workers)
  end

  def add_alias(as)
    @lock.synchronize do
      @display.print_alias as
      @num_methods += 1
    end
  end

  def add_class(klass)
    @lock.synchronize do
      @display.print_class klass
      @num_classes += 1
    end
  end

  def add_file(file)
    @lock.synchronize do
      @display.print_file @num_files, file
      @num_files += 1
    end
  end

  def add_method(method)
    @lock.synchronize do
      @display.print_method method
      @num_methods += 1
    end
  end

  def add_module(mod)
    @lock.synchronize do
      @display.print_module mod
      @num_modules += 1
    end
  end
  
  def done_adding
    @lock.synchronize do
      @display.done_adding
    end
  end

  def print
    puts "Files:   #@num_files"
    puts "Classes: #@num_classes"
    puts "Modules: #@num_modules"
    puts "Methods: #@num_methods"
    puts "Elapsed: " + sprintf("%0.1fs", Time.now - @start)
  end

  class Quiet
    def begin_adding(*) end
    def print_alias(*) end
    def print_class(*) end
    def print_file(*) end
    def print_method(*) end
    def print_module(*) end
    def done_adding(*) end
  end
  
  class Normal
    def initialize(total_files)
      @total_files = total_files
    end
    
    def begin_adding(number_of_workers)
      puts "Parsing sources with #{number_of_workers} thread(s)..."
    end
    
    def print_file(files_so_far, filename)
      progress_bar = sprintf("%3d%% [%2d/%2d]  ",
                             100 * (files_so_far + 1) / @total_files,
                             files_so_far + 1,
                             @total_files)
      
      if $stdout.tty?
        # Print a progress bar, but make sure it fits on a single line. Filename
        # will be truncated if necessary.
        terminal_width = (ENV['COLUMNS'] || 80).to_i
        max_filename_size = terminal_width - progress_bar.size
        if filename.size > max_filename_size
          # Turn "some_long_filename.rb" to "...ong_filename.rb"
          filename = filename[(filename.size - max_filename_size) .. -1]
          filename[0..2] = "..."
        end
        
        # Pad the line with whitespaces so that leftover output from the
        # previous line doesn't show up.
        line = "#{progress_bar}#{filename}"
        padding = terminal_width - line.size
        if padding > 0
          line << (" " * padding)
        end
        
        $stdout.print("#{line}\r")
        $stdout.flush
      else
        puts "#{progress_bar} #{filename}"
      end
    end
    
    def done_adding
      puts "\n"
    end

    def print_alias(*) end
    def print_class(*) end
    def print_method(*) end
    def print_module(*) end
  end

  class Verbose
    def begin_adding(number_of_workers)
      puts "Parsing sources with #{number_of_workers} thread(s)..."
    end
    
    def print_alias(as)
      puts "\t\talias #{as.new_name} #{as.old_name}"
    end

    def print_class(klass)
      puts "\tclass #{klass.full_name}"
    end

    def print_file(files_so_far, file)
      puts file
    end

    def print_method(method)
      puts "\t\t#{method.singleton ? '::' : '#'}#{method.name}"
    end

    def print_module(mod)
      puts "\tmodule #{mod.full_name}"
    end
    
    def done_adding
    end
  end

end


