Middleman.helpers do
  def link_to(title, url="#", params={})
    params.merge!(:href => url)
    params = params.map { |k,v| %Q{#{k}="#{v}"}}.join(' ')
    %Q{<a #{params}>#{title}</a>}
  end
  
  def page_classes(*additional)
    classes = []
    parts = @full_request_path.split('.')[0].split('/')
    parts.each_with_index { |path, i| classes << parts.first(i+1).join('_') }
  
    classes << "index" if classes.empty?
    classes += additional unless additional.empty?
    classes.join(' ')
  end
  
  def asset_url(path)
    path.include?("://") ? path : "/#{path}"
  end
  
  def image_tag(path, options={})
    options[:alt] ||= ""
    capture_haml do
      haml_tag :img, options.merge(:src => asset_url(path))
    end
  end
  
  def javascript_include_tag(path, options={})
    capture_haml do
      haml_tag :script, options.merge(:src => asset_url(path), :type => "text/javascript")
    end
  end
  
  def stylesheet_link_tag(path, options={})
    options[:rel] ||= "stylesheet"
    capture_haml do
      haml_tag :link, options.merge(:href => asset_url(path), :type => "text/css")
    end
  end
end
