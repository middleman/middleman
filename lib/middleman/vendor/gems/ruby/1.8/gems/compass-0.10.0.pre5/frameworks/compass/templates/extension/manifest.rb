description "Generate a compass extension."

file 'stylesheets/main.sass', :to => "stylesheets/_#{File.basename(options[:pattern_name]||options[:project_name]||'main')}.sass"
file 'templates/project/manifest.rb'
file 'templates/project/screen.sass'

help %Q{
  To generate a compass extension:
  compass create my_extension --using compass/extension
}

welcome_message %Q{
For a full tutorial on how to build your own extension see:

http://github.com/chriseppstein/compass/blob/edge/docs/EXTENSIONS.markdown

}, :replace => true

no_configuration_file!
skip_compilation!
