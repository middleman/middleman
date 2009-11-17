module Smusher
  class PunyPng
    def self.converts_gif_to_png?
      false
    end

    def self.optimized_image_data_for(file)
      url = 'http://www.gracepointafterfive.com/punypng_staging/api/optimize'
      response = HTTPClient.post url, { 'img' => File.new(file), 'key' => 'd1b72ab4813da6b69e1d6018303ac690c014599d'}
      response = JSON.parse(response.body.content)
      raise "puny_png: #{response['error']}" if response['error']
      image_url = response['optimized_url']
      raise "no optimized_url found" unless image_url
      open(image_url) { |source| source.read() }
    end
  end
end