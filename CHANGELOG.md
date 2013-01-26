Master
===

3.0.10
====

* Avoid looking in binary files for frontmatter. #728
* Allow nested i18n files. #725
* Better adapt to Rack interface. #709
* Add --force-polling flag. #730, #644

3.0.9
====

* Lock Rack to 1.4.1 until BodyProxy bug is resolved. #709
* Safely de-register Tilt extensions which are missing gems. #713

3.0.8
====

* Directly send binary files in preview and copy them in build, avoiding reading large binary files into memory for rendering. #643 #699
* Make link_to helper ignore QueryString values when looking up Sitemap resources
* Directly copy binary files during build, and stream them during preview, to avoid reading them into memory
* Make sure all paths in Sitemap are using Pathname

3.0.7
====

* Turn html5 boilerplate into a layout
* Fix errors when templates have empty YAML
* Show the hostname when initializing MM
* Fix issues when using Redcarpet inside Slim
* Make automatic_image_sizes avoid SVGs

3.0.6
====
* Make Sitemap more thread-safe.
* Asset-hash fixes in conjunction with Sprockets.
* Proxy improvements.
* Handle directories with a tilde (~) in their path.
* Print better error message which port is already in use.
* Terminal signal improvements, shutsdown correctly when Terminal closed.
* Bundled Normalize.css updated to 2.0.1
* Fixed Encoding extension activation
* Reload i18n on file changes (#616)

3.0.5
====
* Require newer version of listen.
* Handful of sitemap speed improvements.
* Fix previewing of directories with periods in their name.
* Add CLI ability to skip gemfile and bundler init.
* Fix asset_hash when used in conjunction with Rack middleware.
* Fix LiveReload extension issues.

3.0.3-3.0.4
====
* Add reload_paths to server CLI to add additional paths to reload MM on change.
* Re-organize app reloading code, don't need to restart listen every time.

3.0.2
====
* Logger has no such method .warning. Closes #582

3.0.1
====
* HTML5 Boilerplate version 4.0.0
* Use wdm for Windows
* Fix buggy color renaming in built-in CSS minifier. #576
* Fix Sass/Scss filter in Slim templates
* Added SMACSS template
* Give file metadata (such as frontmatter) precedence over path meta. #552
* Add `sass_assets_paths` option for arbitrary sass partial locations.
* Don't catch CoffeeScript errors when in build mode.
* Extract load_paths so they aren't locked into the binary
* Add middleman/rack for better config.ru support
* Use centralized Logger and add benchmark methods

3.0.0
====
* Improve asset methods and link_to by making them more clever and aware of options such as relative_assets and http_prefix
* Refer to --verbose, instead of --debug in CLI error message (#505)
* Cleanup listener setup and teardown
* Update to Padrino 0.10.7 and Thor 0.15 (#495)
* Build output correctly shows update and identical, instead of create for all.
* automatic_directory_matcher (#491)

3.0.0.rc.2
====
* Doing a build now shows identical files (#475)
* asset_hash, minify_javascript, and minify_css can now accept regexes, globs, 
  and procs (#489, #480)
* The `link_to` helper can now accept a sitemap Resource as a URL (#474)
* The preview server now correctly listens for changes (#487, #464)
* HTMLs are now served with a 'utf-8' charset instead of 'utf8' (#478)
* UTF-8 is now the new default encoding for data and templates (#486, #483)
* New :encoding setting that allows users to change default encoding
* You may now use the `use` method with a block when adding Rack middleware
* Middleman now depends on Listen 0.4.5+ and ActiveSupport 3.2.6+
* Attempt to avoid issues with RVM's default Bundler (#466)
* Fix issue where Middleman won't start with Compass 0.12.2.rc.1 (#469)

3.0.0.rc.1
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
* `link_to` is smart about source paths, and can produce relative URLs with the `:relative` option or the sitewide `:relative_links` setting.
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
