require File.expand_path('../../tasks', __FILE__)
require 'rake'
require 'rake/dsl_definition'
require 'thor'
require 'securerandom' unless defined?(SecureRandom)

module PadrinoTasks
  def self.init(init=false)
    Padrino::Tasks.files.flatten.uniq.each { |rakefile| Rake.application.add_import(rakefile) rescue puts "<= Failed load #{ext}" }
    if init
      Rake.application.init
      Rake.application.instance_variable_set(:@rakefile, __FILE__)
      load(File.expand_path('../rake_tasks.rb', __FILE__))
      Rake.application.load_imports
      Rake.application.top_level
    else
      load(File.expand_path('../rake_tasks.rb', __FILE__))
      Rake.application.load_imports
    end
  end
end

def shell
  @_shell ||= Thor::Base.shell.new
end
