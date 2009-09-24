require 'rubygems'
require 'sinatra'
require 'sinatra/maruku'

get "/" do
  #maruku :hello, :layout => false
  maruku :index
end
