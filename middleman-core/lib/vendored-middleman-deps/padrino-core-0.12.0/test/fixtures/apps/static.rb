PADRINO_ROOT = File.dirname(__FILE__) unless defined? PADRINO_ROOT

class StaticDemo < Padrino::Application
  disable :reload
  def self.reload!
    fail 'reload! called'
  end
end

Padrino.load!
