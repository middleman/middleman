master
===

3.4.0
===

* Fix webrick restarts on Ruby 2.2
* Empower link_to in a i18n context.
* Add retina files support on automatic_image_sizes
* Fix woff/woff2 confusion in asset hashing.

3.3.12
===
* The preview server can now serve over HTTPS using the `--https` flag. It will use an automatic self-signed cert which can be overridden using `--ssl_certificate` and `--ssl_private_key`. These settings can also be set in `config.rb`
* The preview server URL will use the local hostname rather than '0.0.0.0'. It will also print out a URL based on the host's public IP in case that's useful.
* The `--host` flag and `config.rb` setting have been removed - the preview server will always bind to all interfaces.

3.3.11
===
* Add `srcset` option to `image_tag`. Also enables them in Markdown.
* Add jruby to the list of envs requiring tzinfo-data.
* Don't lookup resource for path if the path is absolute. Fixes #1195
* Make preview host and port configurable in config.rb and also expose those variables to extensions which are curious. Closes #1477
* Append assets hash to .woff2 files
* Rack support has been broken since v3.3.9, fix that. #1501

3.3.10
===
* Fixes #1469, missing `cattr_accessor` in Redcarpet support.
* Fix slim >= 3.0.0 deprecation warning

3.3.9
===
* Moved main `Application` from requiring to autoloading to work around some double-loading issues in Docker.

3.3.8
===
* Define a mime type for sourcemaps. #1451
* Asset hashing for image references in srcset
* Import patch to bugfix from Padrino Helpers #1401
* Better URI encoding and decoding #1406
* Update version of i18n

3.3.7
===
* Update new project template Gemfile to use HTTPS by default. #1372

3.3.6
===

* Use full paths instead of relative for `listen` gem. Fixes #1374
* Add force option to "middleman init". #1369
* Configuration addition for compass 1 compatibility.
* Catch File read exceptions in frontmatter.
* Remove duplicate attr_accessor. Closes #1352
* Update sass dependency to >= 3.4.0.
* Update compass dependency to >= 1.0.0, < 2.0.0
* Accept pandoc-style YAML frontmatter. #1350
* Add webp to image type lists.

3.3.5
===

* Update Padrino to ~> 0.12.3 (removed breadcrumb helper)
* Update compass-import-once to 1.0.5
* Fix issue with Slim partials. #1327

3.3.4
===

* Fix `automatic_alt_tags` error. #1341
* `partial` now looks for i18n suffixed filenames. #1333
* Allow excluding paths from `gzip`. #1268
* Let LiveReload work on 404 pages.
* Update `listen` dependency.

3.3.3
===

* Fix thread-safety issue #501 which could cause excepts when livereloading.
* Update to support Hooks 0.4.x dep.
* Update to support Padrino 0.12.2+ dep.
* Fix `after_render` manipulation of content. #1278
* Fix combo of compass-import-once and sass-globs. middleman/middleman-sprockets#56

3.3.0-3.3.2
===

* Update Padrino to 0.12.1. Introduces BREAKING CHANGE for Haml. Helpers which take blocks used to require `-` instead of `=` to work correctly. Now, all helpers which output content should use `=`. See: http://www.padrinorb.com/blog/upgrading-padrino-from-0-11-x-to-0-12-0-guide
* Update Haml to 4.x
* Disable Webrick reverse DNS lookup, vastly improving performance when accessing from a VM.
* Ignore `node_modules` in FileWatcher
* Add `tzinfo-data` for Windows users.
* Prefer loading layouts from `layouts_dir`
* Add `before_build` hook.
* Depend on Erubis and remove support for specifying another ERb engine.
* Removed the ability to set the `sass_cache_path`.
* Improved /__middleman/ meta pages. For example, sitemap view now calls out ignored resources, prints data/options better, and shows which special locals are available on a page.
* Bump Uglifier to 2.5.x

3.2.2
===

* Specify the full path to the NEWLINE constant
* Refactor some internals which were dependent on certain order of operations
* Updated i18n dep
* Updated Uglifier dep

3.2.1
===

* Allow path to be passed to page_classes. #1120
* Parallelize gzip extension using four threads. #1116
* Fix locale issue when using gzip extension
* Better handle UTF-8 filenames
* Update Padrino to 0.11.4 and Tilt to 1.4.1

3.2.0
===

* Dropped support for Ruby 1.8
* Dropped empty "middleman-more" gem
* Support the AsciiDoc format
* `page_classes` now prefixes class names starting with numbers with an alpha character. "x" by default.
* AREL-style sitemap query language no longer mutates on filter
* Logging can now be forwarded to a file
* Syntax errors in config.rb no longer hang the server
* Fixed memory leak when adding blocks to resources. #1020
* Support HEAD requests in the server

3.1.6
===

* Magic sitemap-aware links and image references now work when your markdown engine is Kramdown (the default for Middleman).
* Having the build directory be a symlink no longer causes the --clean (default) option to wipe out your build.
* Fix handling paths and URLs with spaces in them. #961
* Loosen up Kramdown dependency to allow for using version 1.2.
* Loosen up Listen dependency so it works with sass betas.
* Look for assets using url_for before falling back to the "images" directory. #1017
* Do not cache generated redirect index file. #1019
* Make an effort to handle spaces in filenames in a way that url_for can handle. #961
* Fix localization via filename extension. #1015

3.1.5
===

* Escape filenames in regexes. Fixes #942.
* Create automated alt tag addition, based on image name.
* Add listener latency option. (Aliased to -l)
* Add support/tests for Redcarpet 3.0.0 features
  - :underline
  - :highlight
  - :disable_indented_code_blocks
*  Fix support for
  - :link_attributes
  - :filter_html

3.1.4
===

* Support kramdown 1.1
* Support redcarpet's :no_links & :no_images. #951

3.1.3
===

* Fixed typo in rack extensions block
* Add support for nojekyll dotfile

3.1.2
===

* Locales regex was broken, selecting .yml files from data folder.
* Fix for implied extensions getting a layout. (Mentioned in #901)git pu
* Added `redirect` command for generating meta refreshes

3.1.1
===

* Check if set is redefining a param at the class level. Fixes #939
* Correctly escape `content_tag` when using a block. Fixes #941

3.1.0 Highlights
===

* Autoload support (moving away from middleman-more)
* New Configuration System
* New v4 Extension API
* `/__middleman' inspector
* Added Ruby 2.0, dropped Ruby 1.9.2
* Fully tested on JRuby 1.9
* Build defaults to --clean

3.1.0.rc.4
===

* Blocks with different templating languages than their layout now work as expected. #860
* Ruby 1.8 users will need to add the following to their Gemfiles:
  platforms :mri_18 do
    gem "ruby18_source_location"
  end
* The `endpoint` method allows the building of Rack-based files or arbitrary content.

3.1.0.rc.2
===

* `layouts_dir` is now configurable
* Custom template classes can now override the file used for creating the project Gemfile.
* Add an "empty" template that produces the minimum necessary structure for a Middleman project.
* Fix ignoring layouts from the sitemap when the source directory has been set to something other than 'source'. #896
* Track test coverage with simplecov
* i18n only autodetects languages in the `locales` root
* Frontmatter cache fixes solve performance regressions found in 3.1.x
* Vendor padrino-* to avoid dep hell
* `middleman-more` gem returns, but it's empty for backwards compat
* Prefer internal files.exists? over ruby's slow File.exists?

3.1.0.rc.1
===

* Move more into core, autoloaded if gems are available.
* DataStore may now be accessed like a hash with #[] and #has_key?. #880
* The i18n extension now supports providing localized templates as separate files, like index.es.html.haml. #816, #823
* The list of regular expressions for which files are ignored by the file watcher are now configurable.
* Revert to Thor 0.15.x
* Revert to padrino-helpers 0.10.x (dependency hell)
* Drop i18n dep to match activesupport at 0.6.1

3.1.0.beta.2
===

* Extension template uses new class-based Extension
* Fix missing children in some sitemap traversal operations. #837
* Add respond_to? to DataStore. #872
* Allow discovery of prerelease gems.  #873
* Include middleman-livereload in default Gemfile
* Update Rack dependency to 1.5.x
* Update to Listen 1.0.x
* Update to padrino-helpers 0.11.x
* Update uglifier to 2.0.x
* Convert all of middleman-more to new class-based Extensions

3.1.0.beta.1
===

* Support Slim 2.0 ::Slim::Embedded
* "middleman build" will clean out old files from the build directory by default now, without needing to pass "--clean". Pass "--no-clean" to disable. #862
* Allow frontmatter to be side-loaded from a neighboring file with a .frontmatter extension: #855
* Allow frontmatter "renderer_options" key to overwrite renderer options on a per-file basis. #859
* A custom :partials_dir may be configured, and partials will be looked up from it. #854
* The sprockets environment is now available before config.rb is run, so you can mess with it.
* Added a "t" helper that delegates to I18n.t, just like Rails. #853.
* I18n will fall back to the default locale if a translation in the current locale is not found. You can disable this behavior by passing `:no_fallbacks => true` when activating `:i18n`. More settings documented at https://github.com/svenfuchs/i18n/wiki/Fallbacks . #853
* Switched default Markdown engine to Kramdown. #852
* Overhaul content-type handling, and add a `:content_type` parameter for `page`, `proxy`, and frontmatter that allows for overriding the default content type. #851
* Fixes for upcoming Sass versions.
* Fix markdown filters in Haml 4 so that they don't throw errors when generating links/images and so they use our magic image_tag/link_to methods. #662
* Fix a number of bugs with i18n. Add a `:lang` option that can be used with `page` or `proxy` to set the I18n.locale of a page. #845
* Directory names in the data folder are treated as part of the data key. #836
* Properly reload the server when files change in "lib" or "helpers". #835
* Replace Rainpress CSS minifier with the one built into Sass.
* Changed 'default' and 'html5' templates to use 'current_page.data.title' instead of 'data.page.title'. #825
* Include file extension in template cache. #798
* Support for Ruby 2.0.0.
* "middleman console" will give you a console where you can mess around inside your middleman context. #775
* Add to Compass import paths instead of resetting them. #707
* There are now metadata pages in the preview server at "/__middleman/" that show information about the sitemap and site configuration. #374 and #776
* The sitemap is now queryable with an ARel-like API. #650
* Reorganize SMACSS template. #591
* No longer bundle native file watchers - add an appropriate gem (rb-fsevent for OS X, rb-inotify for Linux, wdm for windows) to your Gemfile.
* `activate :asset_host, :host => hostname` can be used to configure `:asset_host`.
* Path matchers (for things like ignore and page) correctly work with string matchers. #689
* Configuration has been moved to Middleman::Configuration::ConfigurationManager. This is backwards-compatible, but offers a nicer way of getting and setting configuration for extensions, including documenting those settings and their defaults. #620.

3.0.13
===

* Require Tilt 1.3.6 (older versions have errant .csv template type)
* Unregister Tilt HTML handler
* Fix dynamic multi-byte utf-8 files rebuilding. #806
* Force locale to english for number_to_human_size in the gzip extension. #804
* Don't use the logger from a trap context. Ruby 2.0.0 support. #801.
* Serve extensionless files or dotfiles with text/plain MIME type

3.0.12
===

* Update to listen 0.7.x. No longer depend on rb-inotify. *nix users should add to Gemfile.
* Support Haml 4
* :debug_assets can no longer be turned on in the build environment.
* Helpers now work with JS/CSS files with .erb processing.
* Provide an informative exception when link_to is used improperly.
* Force .svgz files to be treated as binary.
* Add a url_for method that performs the link_to magic URL generation without a link. Make form_for use url_for. #739
* Fix issues when combining relative assets and cache buster.
* Support the .yaml extension for data files.
* Handle non-english default languages in i18n. Fixes #584. #771
* Allow frontmatter to be parsed on templates outside the project root
* Improve detection of binary files. #763
* Add before_render and after_render hooks that can be used by extensions to modify templates before they're rendered or modify the rendered output before it's returned. #761 & #774
* Tightened up dependencies
* Print the command for running middleman in verbose mode with quotes so Bundler doesn't swallow the verbose flag. #750

3.0.11
====

* Mitigate major perf regression caused by the Middleman::Util#binary? method

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
