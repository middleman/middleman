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
  
  def asset_url(path, tld_length = 1)
    "/#{path}"
  end
end
