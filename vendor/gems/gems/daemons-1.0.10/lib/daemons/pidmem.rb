require 'daemons/pid'


module Daemons

  class PidMem < Pid
    attr_accessor :pid
  end

end
