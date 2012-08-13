require "sinatra"

class MySinatra < Sinatra::Base
  get "/" do
    "Hello World (Sinatra)"
  end
end

map "/sinatra" do
  run MySinatra
end
