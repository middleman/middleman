# Reloads classes
def reload!
  Padrino.reload!
end

# Show applications
def applications
  puts "==== List of Mounted Applications ====\n\n"
  Padrino.mounted_apps.each do |app|
    puts " * %-10s mapped to      %s" % [app.name, app.uri_root]
  end
  puts
  Padrino.mounted_apps.map { |app| "#{app.name} => #{app.uri_root}" }
end

# Load apps
Padrino.mounted_apps.each do |app|
  puts "=> Loading Application #{app.app_class}"
  app.app_obj.setup_application!
end
