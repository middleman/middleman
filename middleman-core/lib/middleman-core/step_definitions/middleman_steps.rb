Then /^the file "([^\"]*)" has the contents$/ do |path, contents|
  watch(@app_rack.watcher, 1) do
    write_file(path, contents)
  end
end

Then /^the file "([^\"]*)" is removed$/ do |path|
  watch(@app_rack.watcher, 1) do
    step %Q{I remove the file "#{path}"}
  end
end

# Then /^the listener should shutdown$/ do
#   return unless @app_rack.watcher && @app_rack.watcher.listener
#   @app_rack.watcher.listener.adapter.stop
#   @app_rack.watcher.listener.adapter.started?.should == false
# end

def watch(watcher, n, &block)
  return yield unless watcher

  watcher.wait_for_changes(1, &block)
end
