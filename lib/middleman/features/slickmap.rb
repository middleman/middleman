require 'slickmap'

class Middleman::Base
  def build_sitemap(&block)
    # views - stylesheets
    # public
    # .select
    #   block.call(this)
  end
  
  get '/sitemap.html' do
    @tree = build_sitemap do |file_name|
      true
    end
    haml :sitemap, :layout => false
  end

  use_in_file_templates!
end

__END__

@@ sitemap
%div.title Hello world!!!!!