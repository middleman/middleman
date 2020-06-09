data.store :static_array, ::YAML.load_file(File.expand_path('static_array.yml', File.dirname(__FILE__)))
data.store :static_hash, ::YAML.load_file(File.expand_path('static_hash.yml', File.dirname(__FILE__)))
