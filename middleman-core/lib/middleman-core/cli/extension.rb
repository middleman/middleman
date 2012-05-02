# CLI Module
module Middleman::Cli
  
  # A thor task for creating new projects
  class Extension < Thor
    include Thor::Actions
    
    check_unknown_options!
    
    namespace :extension
    
    # Required path for the new project to be generated
    argument :name, :type => :string

    desc "extension NAME [options]", "Create Middleman extension scaffold NAME"
    
    # The extension task
    # @param [String] name
    def extension
      template "Rakefile", File.join(name, "Rakefile")
      template "gemspec", File.join(name, "#{name}.gemspec")
      template "Gemfile", File.join(name, "Gemfile")
      template "lib/middleman_extension.rb", File.join(name, "lib", "middleman_extension.rb")
      template "lib/lib.rb", File.join(name, "lib", "#{name}.rb")
      template "features/support/env.rb", File.join(name, "features", "support", "env.rb")
      empty_directory File.join(name, "fixtures")
    end
    
    # Template files are relative to this file
    # @return [String]
    def self.source_root
      File.join(File.dirname(__FILE__), "..", "templates", "extension")
    end

  end
end
