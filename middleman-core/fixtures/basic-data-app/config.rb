# frozen_string_literal: true

data.store :static_array, ::YAML.safe_load_file(File.expand_path('static_array.yml', File.dirname(__FILE__)), permitted_classes: [Date, Time, DateTime, Symbol, Regexp], aliases: true)
data.store :static_hash, ::YAML.safe_load_file(File.expand_path('static_hash.yml', File.dirname(__FILE__)), permitted_classes: [Date, Time, DateTime, Symbol, Regexp], aliases: true)
