ROOT = File.expand_path(File.dirname(__FILE__))

task :test do
  ["middleman-core"].each do |g|
    sh "cd #{File.join(ROOT, g)} && bundle exec rake test"
  end
end