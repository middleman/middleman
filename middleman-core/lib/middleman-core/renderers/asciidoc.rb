require 'asciidoctor'

module Middleman
  module Renderers
    module AsciiDoc
      class << self
        def registered(app)
          app.config.define_setting :asciidoc, {
            safe: :safe,
            backend: :html5,
            attributes: %W(showtitle env=middleman env-middleman middleman-version=#{::Middleman::VERSION})
          }, 'AsciiDoc engine options (Hash)'
          app.config.define_setting :asciidoc_attributes, [], 'AsciiDoc custom attributes (Array)'
          app.before_configuration do
            template_extensions adoc: :html
          end

          app.after_configuration do
            # QUESTION should base_dir be equal to docdir instead?
            config[:asciidoc][:base_dir] = source_dir
            config[:asciidoc][:attributes].concat(config[:asciidoc_attributes] || [])
            config[:asciidoc][:attributes] << %(imagesdir=#{File.join((config[:http_prefix] || '/').chomp('/'), config[:images_dir])})
            sitemap.provides_metadata(/\.adoc$/) do |path|
              # read the AsciiDoc header only to set page options and data
              # header values can be accessed via app.data.page.<name> in the layout
              doc = Asciidoctor.load_file path, safe: :safe, parse_header_only: true

              opts = {}
              if doc.attr? 'page-layout'
                case (layout = (doc.attr 'page-layout'))
                when '', 'false'
                  opts[:layout] = false
                else
                  opts[:layout] = layout
                end
              end
              opts[:layout_engine] = (doc.attr 'page-layout-engine') if doc.attr? 'page-layout-engine'
              # TODO: override attributes to set docfile, docdir, docname, etc
              # alternative is to set :renderer_options, which get merged into options by the rendering extension
              # opts[:attributes] = config[:asciidoc][:attributes].dup
              # opts[:attributes].concat %W(docfile=#{path} docdir=#{File.dirname path} docname=#{(File.basename path).sub(/\.adoc$/, '')})

              page = {}
              page[:title] = doc.doctitle
              page[:date] = (doc.attr 'date') unless (doc.attr 'date').nil?
              # TODO: grab all the author information
              page[:author] = (doc.attr 'author') unless (doc.attr 'author').nil?

              { options: opts, page: ::Middleman::Util.recursively_enhance(page) }
            end
          end
        end

        alias_method :included, :registered
      end
    end
  end
end
