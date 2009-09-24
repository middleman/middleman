# Include maruku support
require 'sinatra-maruku'
Middleman.helpers Sinatra::Maruku
Middleman.supported_formats << "maruku"