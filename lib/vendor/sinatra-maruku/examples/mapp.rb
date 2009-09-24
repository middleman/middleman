require 'rubygems'
require 'sinatra/base'
require 'sinatra/maruku'

require 'rack'

class MApp < Sinatra::Base
  helpers Sinatra::Maruku

  get '/' do
    maruku "## hello form modular app"
  end
end

Rack::Handler::Thin.run MApp.new, :Port => 4567
