desc "Publish the release files to RubyForge."
task :release => [ :package ] do
  packages = %w( gem tgz zip ).collect{ |ext| "pkg/#{GEM_NAME}-#{GEM_VERSION}.#{ext}" }

  begin
    sh %{rubyforge login}
    sh %{rubyforge add_release #{RUBY_FORGE_PROJECT} #{GEM_NAME} #{GEM_VERSION} #{packages.join(' ')}}
    sh %{rubyforge add_file #{RUBY_FORGE_PROJECT} #{GEM_NAME} #{GEM_VERSION} #{packages.join(' ')}}
  rescue Exception => e
    puts
    puts "Release failed: #{e.message}"
    puts
    puts "Set PKG_BUILD environment variable if you do a subrelease (0.9.4.2008_08_02 when version is 0.9.4)"
  end
end
