module Smusher
  class SmushIt
    def self.converts_gif_to_png?
      true
    end

    def self.optimized_image_data_for(file)
      #I leave these urls here, just in case it stops working again...
      # url = "http://smush.it/ws.php" # original, redirects to somewhere else..
      # url = "http://developer.yahoo.com/yslow/smushit/ws.php" # official but does not work
      # url = "http://smushit.com/ysmush.it/ws.php" # used at the new page but does not hande uploads
      # url = "http://smushit.eperf.vip.ac4.yahoo.com/ysmush.it/ws.php" # used at the new page but does not hande uploads
        url = 'http://ws1.adq.ac4.yahoo.com/ysmush.it/ws.php'
      response = HTTPClient.post url, { 'files[]' => File.new(file)}
      response = JSON.parse(response.body.content)
      raise "smush.it: #{response['error']}" if response['error']
      image_url = response['dest']
      raise "no dest path found" unless image_url
      open(image_url) { |source| source.read() }
    end
  end
end