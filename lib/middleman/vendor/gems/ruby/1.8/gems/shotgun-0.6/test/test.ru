require 'rack'

app = lambda { |env|
  [200, {'Content-Type'=>'text/plain'}, ['BANG!']] }

use Rack::ContentLength
run app
