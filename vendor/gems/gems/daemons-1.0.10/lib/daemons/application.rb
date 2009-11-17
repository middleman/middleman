require 'daemons/pidfile'
require 'daemons/pidmem'


module Daemons

  class Application
  
    attr_accessor :app_argv
    attr_accessor :controller_argv
    
    # the Pid instance belonging to this application
    attr_reader :pid
    
    # the ApplicationGroup the application belongs to
    attr_reader :group
    
    # my private options
    attr_reader :options
    
    
    SIGNAL = (RUBY_PLATFORM =~ /win32/ ? 'KILL' : 'TERM')
    
    
    def initialize(group, add_options = {}, pid = nil)
      @group = group
      @options = group.options.dup
      @options.update(add_options)
      
      @dir_mode = @dir = @script = nil
      
      unless @pid = pid
        if dir = pidfile_dir
          @pid = PidFile.new(dir, @group.app_name, @group.multiple)
        else
          @pid = PidMem.new
        end
      end
    end
    
    def script
      @script || @group.script
    end
    
    def pidfile_dir
      Pid.dir(@dir_mode || @group.dir_mode, @dir || @group.dir, @script || @group.script)
    end
    
    def output_logfile
      logdir = options[:dir_mode] == :system ? '/var/log' : pidfile_dir
      (options[:log_output] && logdir) ? File.join(logdir, @group.app_name + '.output') : nil
    end
    
    def logfile
      logdir = options[:dir_mode] == :system ? '/var/log' : pidfile_dir
      logdir ? File.join(logdir, @group.app_name + '.log') : nil
    end
    
    # this function is only used to daemonize the currently running process (Daemons.daemonize)
    def start_none
      unless options[:ontop]
        Daemonize.daemonize(nil, @group.app_name) #(logfile)
      else
        Daemonize.simulate
      end
      
      @pid.pid = Process.pid
      
      
      # We need this to remove the pid-file if the applications exits by itself.
      # Note that <tt>at_text</tt> will only be run if the applications exits by calling 
      # <tt>exit</tt>, and not if it calls <tt>exit!</tt> (so please don't call <tt>exit!</tt>
      # in your application!
      #
      at_exit {
        begin; @pid.cleanup; rescue ::Exception; end
        
        # If the option <tt>:backtrace</tt> is used and the application did exit by itself
        # create a exception log.
        if options[:backtrace] and not options[:ontop] and not $daemons_sigterm
          begin; exception_log(); rescue ::Exception; end
        end
          
      }
      
      # This part is needed to remove the pid-file if the application is killed by 
      # daemons or manually by the user.
      # Note that the applications is not supposed to overwrite the signal handler for
      # 'TERM'.
      #
      trap(SIGNAL) {
        begin; @pid.cleanup; rescue ::Exception; end
        $daemons_sigterm = true
        
        if options[:hard_exit]
          exit!
        else
          exit
        end
      }
    end
    
    def start_exec
      if options[:backtrace]
        puts "option :backtrace is not supported with :mode => :exec, ignoring"
      end
      
      unless options[:ontop]
        Daemonize.daemonize(output_logfile, @group.app_name)
      else
        Daemonize.simulate(output_logfile)
      end
      
      # note that we cannot remove the pid file if we run in :ontop mode (i.e. 'ruby ctrl_exec.rb run')
      @pid.pid = Process.pid
        
      ENV['DAEMONS_ARGV'] = @controller_argv.join(' ')      
      # haven't tested yet if this is really passed to the exec'd process...
      
      
      
      Kernel.exec(script(), *(@app_argv || []))
      #Kernel.exec(script(), *ARGV)
    end
    
    def start_load
      unless options[:ontop]
        Daemonize.daemonize(output_logfile, @group.app_name)
      else
        Daemonize.simulate(output_logfile)
      end
      
      @pid.pid = Process.pid
      
      
      # We need this to remove the pid-file if the applications exits by itself.
      # Note that <tt>at_text</tt> will only be run if the applications exits by calling 
      # <tt>exit</tt>, and not if it calls <tt>exit!</tt> (so please don't call <tt>exit!</tt>
      # in your application!
      #
      at_exit {
        begin; @pid.cleanup; rescue ::Exception; end
        
        # If the option <tt>:backtrace</tt> is used and the application did exit by itself
        # create a exception log.
        if options[:backtrace] and not options[:ontop] and not $daemons_sigterm
          begin; exception_log(); rescue ::Exception; end
        end
          
      }
      
      # This part is needed to remove the pid-file if the application is killed by 
      # daemons or manually by the user.
      # Note that the applications is not supposed to overwrite the signal handler for
      # 'TERM'.
      #
      trap(SIGNAL) {
        begin; @pid.cleanup; rescue ::Exception; end
        $daemons_sigterm = true
        
        if options[:hard_exit]
          exit!
        else
          exit
        end
      }
      
      # Now we really start the script...
      $DAEMONS_ARGV = @controller_argv
      ENV['DAEMONS_ARGV'] = @controller_argv.join(' ')
      
      ARGV.clear
      ARGV.concat @app_argv if @app_argv
      
      # TODO: begin - rescue - end around this and exception logging
      load script()
    end
    
    def start_proc
      return unless p = options[:proc]
    
      myproc = proc do 
        # We need this to remove the pid-file if the applications exits by itself.
        # Note that <tt>at_text</tt> will only be run if the applications exits by calling 
        # <tt>exit</tt>, and not if it calls <tt>exit!</tt> (so please don't call <tt>exit!</tt>
        # in your application!
        #
        at_exit {
          begin; @pid.cleanup; rescue ::Exception; end

          # If the option <tt>:backtrace</tt> is used and the application did exit by itself
          # create a exception log.
          if options[:backtrace] and not options[:ontop] and not $daemons_sigterm
            begin; exception_log(); rescue ::Exception; end
          end

        }

        # This part is needed to remove the pid-file if the application is killed by 
        # daemons or manually by the user.
        # Note that the applications is not supposed to overwrite the signal handler for
        # 'TERM'.
        #
        trap(SIGNAL) {
          begin; @pid.cleanup; rescue ::Exception; end
          $daemons_sigterm = true

          if options[:hard_exit]
            exit!
          else
            exit
          end
        }
        
        p.call()
      end
      
      unless options[:ontop]
        @pid.pid = Daemonize.call_as_daemon(myproc, output_logfile, @group.app_name)
      else
        Daemonize.simulate(output_logfile)
        
        @pid.pid = Process.pid
        
        myproc.call
        
# why did we use this??
#         Thread.new(&options[:proc])

# why did we use the code below??
        # unless pid = Process.fork
        #   @pid.pid = pid
        #   Daemonize.simulate(logfile)
        #   options[:proc].call
        #   exit
        # else
        #   Process.detach(@pid.pid)
        # end
      end
    end
    
    
    def start
      @group.create_monitor(@group.applications[0] || self) unless options[:ontop]  # we don't monitor applications in the foreground
      
      case options[:mode]
        when :none
          # this is only used to daemonize the currently running process
          start_none
        when :exec
          start_exec
        when :load
          start_load
        when :proc
          start_proc
        else
          start_load
      end
    end
    
#     def run
#       if @group.controller.options[:exec]
#         run_via_exec()
#       else
#         run_via_load()
#       end
#     end
#      
#     def run_via_exec
#       
#     end
#     
#     def run_via_load
#       
#     end


    # This is a nice little function for debugging purposes:
    # In case a multi-threaded ruby script exits due to an uncaught exception
    # it may be difficult to find out where the exception came from because
    # one cannot catch exceptions that are thrown in threads other than the main
    # thread.
    #
    # This function searches for all exceptions in memory and outputs them to STDERR
    # (if it is connected) and to a log file in the pid-file directory.
    #
    def exception_log
      return unless logfile
      
      require 'logger'
      
      l_file = Logger.new(logfile)
      
      # the code below finds the last exception
      e = nil
      
      ObjectSpace.each_object {|o|
        if ::Exception === o
          e = o
        end
      }
     
      l_file.info "*** below you find the most recent exception thrown, this will be likely (but not certainly) the exception that made the application exit abnormally ***"
      l_file.error e
      
      l_file.info "*** below you find all exception objects found in memory, some of them may have been thrown in your application, others may just be in memory because they are standard exceptions ***"
      
      # this code logs every exception found in memory
      ObjectSpace.each_object {|o|
        if ::Exception === o
          l_file.error o
        end
      }
      
      l_file.close
    end
    
    
    def stop
      if options[:force] and not running?
        self.zap
        return
      end
      
      # Catch errors when trying to kill a process that doesn't
      # exist. This happens when the process quits and hasn't been
      # restarted by the monitor yet. By catching the error, we allow the
      # pid file clean-up to occur.
      begin
        Process.kill(SIGNAL, @pid.pid)
      rescue Errno::ESRCH => e
        puts "#{e} #{@pid.pid}"
        puts "deleting pid-file."
      end
      
      # We try to remove the pid-files by ourselves, in case the application
      # didn't clean it up.
      begin; @pid.cleanup; rescue ::Exception; end
      
    end
    
    def zap
      @pid.cleanup
    end
    
    def zap!
      begin; @pid.cleanup; rescue ::Exception; end
    end
    
    def show_status
      running = self.running?
      
      puts "#{self.group.app_name}: #{running ? '' : 'not '}running#{(running and @pid.exist?) ? ' [pid ' + @pid.pid.to_s + ']' : ''}#{(@pid.exist? and not running) ? ' (but pid-file exists: ' + @pid.pid.to_s + ')' : ''}"
    end
    
    # This function implements a (probably too simle) method to detect
    # whether the program with the pid found in the pid-file is still running.
    # It just searches for the pid in the output of <tt>ps ax</tt>, which
    # is probably not a good idea in some cases.
    # Alternatives would be to use a direct access method the unix process control
    # system.
    #
    def running?
      if @pid.exist?
        return Pid.running?(@pid.pid)
      end
      
      return false
    end
  end
  
end