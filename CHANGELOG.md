master
===

* Switch from Ruby Sass to SassC.
* `relative_assets` extension overrides local `relative: false` option to stylesheet/javascript tag helpers.

# 4.0.0.rc.1

* Removed ability to use JSON as frontmatter. Still allowed in data/ folder.
* Added YAML data postscript. Like frontmatter, but reversed. Attach content after the key/value data as a `:postscript` key to the data structure (if Hash).

# 4.0.0.beta.2

* Fixed regression causing exceptions to be silently thrown away outside of `--verbose` mode in the dev server.
* Pull in `--ssl` option from stable.
* Replace `hooks` gem with custom callback solution.

# 4.0.0.beta.1

* Add `resources` class method to extensions to allow simple string-based resource generation.
* rename `app.add_to_instance` to `Extension.expose_to_application` for adding extension-local methods to the shared app instance.
* rename `app.add_to_config_context` to `Extension.expose_to_config` for adding extension-local methods to the sandboxed scope of `config.rb`
* Add `Extension.expose_to_templates`, which auto binds copies of extension-local methods into a Template context.
* Remove side-loading of CLI tasks from `tasks/`
* Add the option of naming `config.rb` as `middleman.rb`.
* Builder extracted from Thor. `after_build` hook now passes an instance of a Builder instead of the Thor CLI.
* New FileWatcher API.
* Remove the `partials_dir` setting. Partials should live next to content, or be addressed with absolute paths.
* Partials must be named with a leading underscore. `_my_snippet.html.erb`, not `my_snippet.html.erb`.
* Removed the `proxy` and `ignore` options for the `page` command in `config.rb`. Use the `proxy` and `ignore` commands instead of passing these options to `page`.
* The `page` command in `config.rb` can now be used to add data to the page via the `data` argument. It is accessed the same way as frontmatter data, via `current_resource.data`.
* Add support for `environments` with the `-e` CLI flag. Loads additional config from `environments/envname.rb`. Removed `development?` helper in favor of `environment?(:development)`. Added `server?` helper to differentiate between build and server mode.
* Removed `with_layout`. Use loops of `page` instead.
* Removed Queryable Sitemap API
* Removed `css_compressor` setting, use `activate :minify_css, :compressor =>` instead.
* Removed `js_compressor` setting, use `activate :minify_javascript, :compressor =>` instead.
* Removed ability to server folders of content statically (non-Middleman projects).
* Prevent local templates being loaded when $HOME is not set
* Removed "Implied Extension feature"
* Remove 'upgrade' and 'install' CLI commands.
* Gemfile may be in a parent directory of your Middleman project root (where 'config.rb' is).
* All dependencies for your Middleman project must be expressed in `Gemfile` - Bundler is no longer optional.
* Asciidoc information now available with the `asciidoc` local, which is a normal hash.
* Remove `page` template local. Use `current_resource` instead.
* Dropped support for providing a block to `page` & `proxy`.
* Dropped support for instance variables inside templates.
* Moved all rendering into `TemplateRenderer` and `FileRenderer`
* Placed all template evaluation inside the `TemplateContext` class
* Remove deprecated `request` instance
* Remove old module-style extension support
* Placed all `config.rb` evaluation inside the `ConfigContext` class
* The preview server can now serve over HTTPS using the `--https` flag. It will use an automatic self-signed cert which can be overridden using `--ssl_certificate` and `--ssl_private_key`. These settings can also be set in `config.rb`
