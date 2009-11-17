$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

def template_path(template)
  File.expand_path(File.join(File.dirname(__FILE__), 'templates', template))
end

def result_path(result)
  File.expand_path(File.join(File.dirname(__FILE__), 'results', result))
end

require 'templater.rb'
require 'rubygems'
require 'spec'
require 'spec/autorun'
require 'fileutils'

# Added a cross-platform temporary directory helper
# This was taken from MSpec
# http://github.com/rubyspec/mspec/tree/master
# http://github.com/rubyspec/mspec/tree/master/lib/mspec/helpers/tmp.rb
module TmpDirHelper
  def tmp(name)
    unless @spec_temp_directory
      [ "/private/tmp", "/tmp", "/var/tmp", ENV["TMPDIR"], ENV["TMP"],
        ENV["TEMP"], ENV["USERPROFILE"] ].each do |dir|
        if dir and File.directory?(dir) and File.writable?(dir)
          temp = File.expand_path dir
          temp = File.readlink temp if File.symlink? temp
          @spec_temp_directory = temp
          break
        end
      end
    end

    File.join @spec_temp_directory, name
  end
end

# Add it to Object
Object.send(:include, TmpDirHelper)

class MatchActionNames
  def initialize(*names)
    @names = names.map{|n| n.to_s}
  end

  def matches?(actual)
    @actual = actual
    @actual.map{|a| a.name.to_s}.sort == @names.sort
  end

  def failure_message
    "expected #{@actual.inspect} to have action names #{@names.inspect}, but they didn't"
  end

  def negative_failure_message
    "expected #{@actual.inspect} not to have action names #{@names.inspect}, but they did"
  end
end

def have_names(*names)
  MatchActionNames.new(*names)
end

