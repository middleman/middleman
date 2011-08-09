module Middleman
  def self.templates_path
    File.join(File.expand_path("~/"), ".middleman")
  end
end

class Middleman::Templates::Local < Middleman::Templates::Base
  def self.source_root
    Middleman.templates_path
  end

  def build_scaffold
    directory options[:template].to_s, location
  end  
end

Dir[File.join(Middleman.templates_path, "*")].each do |dir|
  next unless File.directory?(dir)
  Middleman::Templates.register(File.basename(dir).to_sym, Middleman::Templates::Local)
end
