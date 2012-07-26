After do
  if @app_rack && @app_rack.watcher
    @app_rack.watcher.stop
  end
end