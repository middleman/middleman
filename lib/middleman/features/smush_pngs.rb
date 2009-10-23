require 'json'
require 'open-uri'

begin
  require 'httpclient'
rescue LoadError
  puts "httpclient not available. Install it with: gem install httpclient"
end

module Middleman
  module SmushPngs
    def self.included(base)
      base.supported_formats << "png"
    end
    
    def render_path(file)
      if File.extname(file) == ".png"
        file = File.join(options.public, file)
        optimized = optimized_image_data_for(file)

        begin
          raise "Error: got larger" if size(file) < optimized.size
          raise "Error: empty file downloaded" if optimized.size < 20

          optimized
        rescue
          File.read(file)
        end
      else
        super
      end
    end

  protected
    def size(file)
      File.exist?(file) ? File.size(file) : 0
    end
    
    def optimized_image_data_for(file)
      # I leave these urls here, just in case it stops working again...
      # url = "http://smush.it/ws.php" # original, redirects to somewhere else..
      url = 'http://ws1.adq.ac4.yahoo.com/ysmush.it/ws.php'
      # url = "http://developer.yahoo.com/yslow/smushit/ws.php" # official but does not work
      # url = "http://smushit.com/ysmush.it/ws.php" # used at the new page but does not hande uploads
      # url = "http://smushit.eperf.vip.ac4.yahoo.com/ysmush.it/ws.php" # used at the new page but does not hande uploads
      response = HTTPClient.post url, { 'files[]' => File.new(file) }
      response = JSON.parse(response.body.content)
      raise "smush.it: #{response['error']}" if response['error']
      image_url = response['dest']
      raise "no dest path found" unless image_url
      open(image_url) { |source| source.read() }
    end
  end
  
  class Base
    include Middleman::SmushPngs
  end
end