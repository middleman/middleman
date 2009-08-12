# Sinatra Maruku Extension

The *sinatra-maruku* extension provides `maruku` helper method
for rendering Maruku templates.

To install it, run: 

    sudo gem install wbzyl-sinatra-maruku -s http://gems.github.com

To test it, create a simple Sinatra application:

    # app.rb
    require 'rubygems'
    require 'sinatra'
      
    gem 'wbzyl-sinatra-maruku'
    require 'sinatra/maruku'
    
    get "/" do
      maruku "# Hello Maruku"
    end

and run it with:

    ruby app.rb

The result could be seen at *http://localhost:4567*.

Another example could be find in the *examples* directory. 
Run it with:

    rackup -p 4567 config.ru

and visit *http://localhost:4567* to contemplate the sheer 
beauty of rendered text written in Maruku notation.


## Two links to Maruku related material

* [Maruku features](http://maruku.rubyforge.org/maruku.html)
* [Literate Maruku](http://www.slideshare.net/schmidt/literate-maruku)


## Template Languages (*update to The Sinatra Book*) 

### Maruku Templates

This helper method:

    get '/' do
      maruku :index
    end

renders template *./views/index.maruku*.

If a layout named *layout.maruku* exists, it will be used each time
a template is rendered.

You can disable layouts by passing `:layout => false` 
to *maruku* helper. For example

    get '/' do
      maruku :index, :layout => false
    end

You can set a different layout from the default one with:

    get '/' do
      maruku :index, :layout => :application
    end

This renders *./views/index.maruku* template
within *./views/application.maruku* layout.


## Sample layout for Maruku templates

    CSS: /stylesheets/application.css /stylesheets/print.css
    Lang: pl
    Title: Hello Maruku 
    LaTeX preamble: preamble.tex
    
    # Hello Maruku  {.header}
    
    <%= yield %>
