PADRINO_ROOT = File.dirname(__FILE__) unless defined? PADRINO_ROOT
PADRINO_ENV = 'test' unless defined? PADRINO_ENV

require 'padrino-core'
require 'slim'

class RenderUser
  attr_accessor :name
  def initialize(name); @name = name; end
end

class RenderDemo < Padrino::Application
  register Padrino::Rendering
  register Padrino::Helpers

  configure do
    set :logging, false
    set :padrino_logging, false
  end

  # get current engines from partials
  get '/current_engine' do
    render :current_engine
  end

  # get current engines from explicit engine partials
  get '/explicit_engine' do
    render :explicit_engine
  end

  # partial with object
  get '/partial/object' do
    partial 'template/user', :object => RenderUser.new('John'), :locals => { :extra => "bar" }
  end

  # partial with collection
  get '/partial/collection' do
    partial 'template/user', :collection => [RenderUser.new('John'), RenderUser.new('Billy')], :locals => { :extra => "bar" }
  end

  # partial with locals
  get '/partial/locals' do
    partial 'template/user', :locals => { :user => RenderUser.new('John'), :extra => "bar" }
  end

  # partial starting with forward slash
  get '/partial/foward_slash' do
    partial '/template/user', :object => RenderUser.new('John'), :locals => { :extra => "bar" }
  end
end
