page '/data.html', layout: false
page '/data3.html', layout: false

data.store :static_array, ::YAML.load_file('static_array.yml')
data.store :static_hash, ::YAML.load_file('static_hash.yml')
