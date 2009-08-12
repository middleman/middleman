# Include maruku support
require File.join(File.dirname(__FILE__), '..', '..', 'vendor', 'sinatra-maruku', 'lib', 'sinatra', 'maruku')
Middleman.helpers Sinatra::Maruku
Middleman.supported_formats << "maruku"