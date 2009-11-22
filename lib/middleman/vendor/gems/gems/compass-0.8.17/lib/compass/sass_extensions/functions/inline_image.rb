require 'base64'
module Compass::SassExtensions::Functions::InlineImage

  def inline_image(path, mime_type = nil)
    path = path.value
    real_path = File.join(Compass.configuration.project_path, Compass.configuration.images_dir, path)
    url = "url('data:#{compute_mime_type(path,mime_type)};base64,#{data(real_path)}')"
    Sass::Script::String.new(url)
  end

private
  def compute_mime_type(path, mime_type)
    return mime_type if mime_type
    case path
    when /\.png$/i
      'image/png'
    when /\.jpe?g$/i
      'image/jpeg'
    when /\.gif$/i
      'image/gif'
    when /\.([a-zA-Z]+)$/
      "image/#{Regexp.last_match(1).downcase}"
    else
      raise Compass::Error, "A mime type could not be determined for #{path}, please specify one explicitly."
    end
  end

  def data(real_path)
    if File.readable?(real_path)
      Base64.encode64(File.read(real_path)).gsub("\n","")
    else
      raise Compass::Error, "File not found or cannot be read: #{real_path}"
    end
  end
end
