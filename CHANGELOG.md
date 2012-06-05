3.0.rc1
====
* Split into 3 gems (middleman-core, middleman-more and middleman which simply includes both)
* Rewritten to work directly with Rack (Sinatra apps can still be mounted)
* Sitemap maintains own state
* New Extension Registration API
* Remove old 1.x mm- binaries and messaging
* New default layout functionality: https://github.com/middleman/middleman/issues/165
* Enable chained templates outside of sprockets (file.html.markdown.erb)
* Sitemap object representing the known world
* FileWatcher proxies file change events
* Unified callback solution
* Removed Slim from base install. Will need to be installed and required by the user (in - config.rb)
* Activate mobile html5boilerplate template
* Update to Redcarpet for Markdown (breaks Haml :markdown filter)
* Return correct exit codes (0 for success, 1 for failure) from CLI
* Yard code docs: http://rubydoc.info/github/middleman/middleman
* config.rb and extensions can add command-line commands
* Nested layouts using `wrap_layout` helper
* Support for placekitten.com
* Added MM_ROOT environmental variable
* activating extensions can now take an options hash
* Don't re-minify files with ".min" in their name
* Serve purely static folders directly (without source/ and config.rb)
* Set ignored files and disable directory_indexes from YAML frontmatter
* Automatically load helper modules in helpers/ directory
* Add pid for cleanup
* Use guard/listen for file watching
* Merge full i18n support
* Implied file extensions (style.scss => style.css)
* Padrino 0.10.6
* `middleman init` generates a `Gemfile` by default.
* Errors stop the build and print a stacktrace rather than silently getting printed into files.
* `with_layout` works with globs or regexes.
* Setting `directory_index` from `page` with a glob or regex now works.
* `:gzip` extension for pre-gzipping files for better compression with no server CPU cost.
* `:asset_hash` extension that generates unique-by-content filenames for assets and rewrites references to use those filenames, so you can set far-future expires on your assets.
* Removed the `--relative` CLI option.
* Properly output Compass-generated sprited images.
* Switch built-in CSS compressor to Rainpress.
* Automatically load helper modules from `helpers/`, like Rails.
* `ignore` and `page` both work with file globs or regexes.
* `layout`, `ignore`, and `directory_index` can be set from front matter.
* JavaScript and CSS are minified no matter where they are in the site, including in inline code blocks.
* Files with just a template extension get output with the correct exension (foo.erb => foo.html)
* Include vendored assets in sprockets path.
* Finally support Compass in Sprockets! Thanks to @xdite and @petebrowne
* Moved Sprockets into an extension
* Support loading Less @imports

2.0.14
====
* Minor fix for i18n

2.0.13.2
====
* Update Windows eventmachine dep

2.0.13.1
====
* build --clean shouldn't remove dotfiles

2.0.13
====
* middleman build --clean keeps the build directory clean of leftover files
* Padrino 0.10.5 and Rack 1.3.5

2.0.12
====
* Sinatra 1.3.1 and Padrino 0.10.4

2.0.11
=====
* Lock Padrino and Sinatra versions (for now)

2.0.9
=====
* Added --glob option to build which only builds matching files
* Allow data/ files to be in JSON format as well
* Enabled Liquid {% include %} tag
* RubyInstaller-specific gem
* Allow access to data/ in config.rb
* Add mobile html5boilerplate template

2.0.8
=====
* Support accessing variables and data objects in ERb Sprockets files (library.js.coffee.erb)
* Make :markdown_engine support simple symbol names (:maruku instead of ::Tilt::MarkukuTemplate)
* Update Padrino deps to 0.10.2
* Include therubyracer on *nix
* Enable frontmatter for Liquid templates

2.0.7
=====
* Updated HTML5 Boilerplate to v2
* Make Rails 3.1 javascript gems available to Sprockets

2.0.6
=====
* Pulled out livereload feature into its own extension, still installed by default.

2.0.5
=====
* Vendored Padrino 0.10.0

2.0.4
=====
* Pulled out undocumented remote data feature into its own extension

2.0.3
=====
* Pulled out undocumented Blog feature into its own extension

2.0.2
=====
* Fixed Sprockets circular error
* Added auto-requiring extensions

2.0.0
=====
* Guard-powered auto-reloading of config.rb
* Guard LiveReload
* Sprockets JS
* Refactored Dynamically Reloadable Core
* Combine views/ and public/ into a single source/ folder.
* Support YAML front-matter
* Added callback to run code after Compass is configured
* Added support for a compass.config file which is passed directly to Compass
* Blog-aware Feature (and project template)
* Thor-based, unified `middleman` binary
* :directory_indexes feature
