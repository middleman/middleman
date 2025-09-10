require 'middleman-core/renderers/redcarpet'

class LinksInBold < Middleman::Renderers::MiddlemanRedcarpetHTML
  def link(link, title, content)
    scope.link_to("**#{content}**", link, { title: title })
  end
end
