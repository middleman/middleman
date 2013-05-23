require 'rbconfig'

module Padrino
  ##
  # This method return the correct location of padrino bin or
  # exec it using Kernel#system with the given args
  #
  # @param [Array] args
  #   command or commands to execute
  #
  # @return [Boolean]
  #
  # @example
  #   Padrino.bin('start', '-e production')
  #
  def self.bin(*args)
    @_padrino_bin ||= [self.ruby_command, File.expand_path("../../../bin/padrino", __FILE__)]
    args.empty? ? @_padrino_bin : system(args.unshift(@_padrino_bin).join(" "))
  end

  ##
  # Return the path to the ruby interpreter taking into account multiple
  # installations and windows extensions.
  #
  # @return [String]
  #   path to ruby bin executable
  #
  def self.ruby_command
    @ruby_command ||= begin
      ruby = File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])
      ruby << RbConfig::CONFIG['EXEEXT']

      # escape string in case path to ruby executable contain spaces.
      ruby.sub!(/.*\s.*/m, '"\&"')
      ruby
    end
  end
end # Padrino
