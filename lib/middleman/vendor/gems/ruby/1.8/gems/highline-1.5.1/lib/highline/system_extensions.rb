#!/usr/local/bin/ruby -w

# system_extensions.rb
#
#  Created by James Edward Gray II on 2006-06-14.
#  Copyright 2006 Gray Productions. All rights reserved.
#
#  This is Free Software.  See LICENSE and COPYING for details.

class HighLine
  module SystemExtensions
    module_function
    
    #
    # This section builds character reading and terminal size functions
    # to suit the proper platform we're running on.  Be warned:  Here be
    # dragons!
    #
    begin
      # Cygwin will look like Windows, but we want to treat it like a Posix OS:
      raise LoadError, "Cygwin is a Posix OS." if RUBY_PLATFORM =~ /\bcygwin\b/i
      
      require "Win32API"             # See if we're on Windows.

      CHARACTER_MODE = "Win32API"    # For Debugging purposes only.

      #
      # Windows savvy getc().
      # 
      # 
      def get_character( input = STDIN )
        @stdin_handle ||= GetStdHandle(STD_INPUT_HANDLE)
        
        begin
            SetConsoleEcho(@stdin_handle, false)
            input.getbyte
        ensure
            SetConsoleEcho(@stdin_handle, true)
        end        
      end

      # A Windows savvy method to fetch the console columns, and rows.
      def terminal_size
        stdout_handle = GetStdHandle(STD_OUTPUT_HANDLE)
        
        bufx, bufy, curx, cury, wattr, left, top, right, bottom, maxx, maxy =
          GetConsoleScreenBufferInfo(stdout_handle)
        return right - left + 1, bottom - top + 1
      end

      # windows savvy console echo toggler
      def SetConsoleEcho( console_handle, on )
        mode = GetConsoleMode(console_handle)
        
        # toggle the console echo bit
        if on
            mode |=  ENABLE_ECHO_INPUT
        else
            mode &= ~ENABLE_ECHO_INPUT
        end
        
        ok = SetConsoleMode(console_handle, mode)    
      end
      
      # win32 console APIs
      
      STD_INPUT_HANDLE  = -10
      STD_OUTPUT_HANDLE = -11
      STD_ERROR_HANDLE  = -12

      ENABLE_PROCESSED_INPUT    = 0x0001
      ENABLE_LINE_INPUT         = 0x0002
      ENABLE_WRAP_AT_EOL_OUTPUT = 0x0002
      ENABLE_ECHO_INPUT         = 0x0004
      ENABLE_WINDOW_INPUT       = 0x0008
      ENABLE_MOUSE_INPUT        = 0x0010
      ENABLE_INSERT_MODE        = 0x0020
      ENABLE_QUICK_EDIT_MODE    = 0x0040 

      @@apiGetStdHandle               = nil
      @@apiGetConsoleMode             = nil
      @@apiSetConsoleMode             = nil
      @@apiGetConsoleScreenBufferInfo = nil      
      
      def GetStdHandle( handle_type )
        @@apiGetStdHandle ||= Win32API.new( "kernel32", "GetStdHandle",
                                            ['L'], 'L' )
        
        @@apiGetStdHandle.call( handle_type )
      end
        
      def GetConsoleMode( console_handle )
        @@apiGetConsoleMode ||= Win32API.new( "kernel32", "GetConsoleMode",
                                              ['L', 'P'], 'I' )
        
        mode = ' ' * 4
        @@apiGetConsoleMode.call(console_handle, mode)
        mode.unpack('L')[0]
      end

      def SetConsoleMode( console_handle, mode )
        @@apiSetConsoleMode ||= Win32API.new( "kernel32", "SetConsoleMode",
                                              ['L', 'L'], 'I' )

        @@apiSetConsoleMode.call(console_handle, mode) != 0
      end            

      def GetConsoleScreenBufferInfo( console_handle )
        @@apiGetConsoleScreenBufferInfo ||=
          Win32API.new( "kernel32", "GetConsoleScreenBufferInfo",
                        ['L', 'P'], 'L' )

        format = 'SSSSSssssSS'
        buf    = ([0] * format.size).pack(format)        
        @@apiGetConsoleScreenBufferInfo.call(console_handle, buf)
        buf.unpack(format)
      end   
      
    rescue LoadError                  # If we're not on Windows try...
      begin
        require "termios"             # Unix, first choice.

        CHARACTER_MODE = "termios"    # For Debugging purposes only.

        #
        # Unix savvy getc().  (First choice.)
        # 
        # *WARNING*:  This method requires the "termios" library!
        # 
        def get_character( input = STDIN )
          old_settings = Termios.getattr(input)

          new_settings                     =  old_settings.dup
          new_settings.c_lflag             &= ~(Termios::ECHO | Termios::ICANON)
          new_settings.c_cc[Termios::VMIN] =  1

          begin
            Termios.setattr(input, Termios::TCSANOW, new_settings)
            input.getbyte
          ensure
            Termios.setattr(input, Termios::TCSANOW, old_settings)
          end
        end
      rescue LoadError             # If our first choice fails, default.
        CHARACTER_MODE = "stty"    # For Debugging purposes only.

        #
        # Unix savvy getc().  (Second choice.)
        # 
        # *WARNING*:  This method requires the external "stty" program!
        # 
        def get_character( input = STDIN )
          raw_no_echo_mode

          begin
            input.getbyte
          ensure
            restore_mode
          end
        end
        
        #
        # Switched the input mode to raw and disables echo.
        # 
        # *WARNING*:  This method requires the external "stty" program!
        # 
        def raw_no_echo_mode
          @state = `stty -g`
          system "stty raw -echo cbreak isig"
        end
        
        #
        # Restores a previously saved input mode.
        # 
        # *WARNING*:  This method requires the external "stty" program!
        # 
        def restore_mode
          system "stty #{@state}"
        end
      end
      
      # A Unix savvy method to fetch the console columns, and rows.
      def terminal_size
        if /solaris/ =~ RUBY_PLATFORM and
           `stty` =~ /\brows = (\d+).*\bcolumns = (\d+)/
          [$2, $1].map { |c| x.to_i }
        else
          `stty size`.split.map { |x| x.to_i }.reverse
        end
      end
    end
  end
end
