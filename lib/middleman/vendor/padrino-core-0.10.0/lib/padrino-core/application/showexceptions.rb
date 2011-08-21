module Padrino
  ##
  # This module extend Sinatra::ShowExceptions adding Padrino as "Framework"
  #
  class ShowExceptions < Sinatra::ShowExceptions
    def frame_class(frame)
      if frame.filename =~ /lib\/sinatra.*\.rb|lib\/padrino.*\.rb/
        "framework"
      elsif (defined?(Gem) && frame.filename.include?(Gem.dir)) ||
            frame.filename =~ /\/bin\/(\w+)$/ ||
            frame.filename =~ /Ruby\/Gems/
        "system"
      else
        "app"
      end
    end
  end # ShowExceptions
end # Padrino