PADRINO_ROOT = File.dirname(__FILE__) unless defined? PADRINO_ROOT

class SystemDemo < Padrino::Application
  set :reload, true
end

SystemDemo.controllers do
  get '/' do
    resolv
  end
end

Padrino.load!
