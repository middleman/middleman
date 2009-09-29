

# def cache_buster
#   if File.readable?(real_path)
#     File.mtime(real_path).strftime("%s") 
#   else
#     $stderr.puts "WARNING: '#{File.basename(path)}' was not found (or cannot be read) in #{File.dirname(real_path)}"
#   end
# end