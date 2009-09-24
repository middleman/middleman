# Include markaby support
require 'sinatra-markaby'
Middleman.helpers Sinatra::Markaby
Middleman.supported_formats << "mab"