# Changelog

All notable changes to this project will be documented in this file.

## 4.6.1

- Allow upgrade to thor 1.3 (#2811)
- Fix regression when visiting sitemap and config page (#2820)

## 4.6.0

- Update Rubies matrix support (add: 3.3 and 3.4, remove: 2.5, 2.6)
- Allow users to use newer versions of Active Support (#2670, #2797)
- Update Uglifier (#2671)
- Unlock Contracts version restriction (#2687)
- Delete unnecessary "backports" runtime dep (#2751)
- Move runtime deps to middleman-core gem (#2750)
- Allow to use newer Liquid versions in Ruby 3+ (#2771)
- Downcase Rack headers (#2706)
- Support Rack 3 (#2776)
- Support newer Tilt versions (#2772, #2774, #2775)
- Support Slim 5 and remove Less support (#2777)
- Internal clean up (#2749, #2782, #2736, #2742)

## 4.5.1

- Lock thor dependency to 1.2.x

## 4.5.0

- Support Haml 6 (#2590)
- Add support for Ruby 3.1 (#2635)
- Switch from Webrick to Addressable for uri encode/decode (#2622)
- Fix 18n fallback when "mount_at_root" is false (4.x) (#2605)
- external pipeline: add option to ignore process exit code (#2623)
- Backport of i18n lookup table changes to 4.x (#2604)

## 4.4.3

- Lock haml to < 6.0 (#2570)
- Allow url_for to override current_resource (#2567)
- Allow users to use Active Support 7.0 (#2552)

## 4.4.2

- Use compiled regex for performance improvement (#2502)

## 4.4.1

- Yanked

## 4.4.0

- Ruby 3.0 support.
- ActiveSupport 6.1 (drop support for Ruby 2.4)
- Remove Stylus support
- Support TOML as frontmatter and data.

## 4.3.11

- Fix URI.unescape deprecation warning (#2312)

## 4.3.10

- Fix liquid page compilation (#2083)

## 4.3.9

- Bad build, yanked.

## 4.3.8

- Update kramdown to avoid CVE-2020-14001 in v4 (#2348)

## 4.3.7

- Allow ActiveSupport a wider range to avoid security warnings. #2327

## 4.3.6

- Reset Content-Length header when rewriting (#2316)
- Add Ruby 2.7.0 to CI

## 4.3.5

- Fix i18n with anchor v4 (#2287)

## 4.3.4

- Fix using the `:anchor` argument with i18n's `url_for`. #2286

## 4.3.4

- Fix `ignore` of files controlled by i18n. #2039 #2143

## 4.3.3

- Add `--bail` to fail a build upon the first error and show the error messages. (#2246)

## 4.3.2

- Resolve Haml 5 warnings (#2149)

## 4.3.1

- Fix sassc imports of gem files that expect old sass to be present.

## 4.3.0

- Only SassC from now on.
- Fix regression (all the way back to v3) for Integer/Date keys in YAML. #2238
- Fix API to allow rack server according to docs (middleman/middlemanapp.com#794)
- Require i18n ~> 0.8.0 to handle 0.7.0 security issue.
- Allow Bundler 2

## 4.2.1

- Fix some issues with Ruby 2.4.0

## 4.2.0

Fix #1951. A failed build would "clean" all files in build. Possibly breaking change, "clean" and "after_build" are only run for sucessful builds.

## 4.1.14

Fix #2019. Always logging boolean on starting up.

## 4.1.13

- Change how config options are passed to Thor. Removes new Thor warnings from #2017

## 4.1.12

- Fix broken `ignore { |p| true }` form.

## 4.1.11

- Upgrade to Rack 2.

## 4.1.10

- Fix unicode issues in URL deeplinks.
- Add prefix option to asset_hash (#1949)

## 4.1.9

- Fix `--watcher-*` CLI flags.
- Allow spaces in paths to work with `link_to`. Fixes #1914
- Add support for dotenv
- Fix asset_url with asset_hash (#1919)
- Allow partial lookups without a current_resource (#1912)

## 4.1.8

- Expose `development?` and `production?` helpers to template context.
- require the `try` core extension (#1911)
- Fix contract for Sitemap::Store.register_resource_list_manipulator (#1907)
- Loosen contract on Resource#source_file to Maybe[String](#1906)
- Let collection loops access ConfigContext for helpers. #1879
- Use https:// to clone templates (#1901)
- Allow numbers to be unique page_ids (#1886)
- Prevent infinite loop when encountering files where base filename is a possible templating engine

## 4.1.7

- Upgrade fastimage to 2.0
- Fix shutdown of external_pipeline commands when config.rb is changed. #1877
- Allow calls to `app.` to work as collections after initial config parse. #1876

## 4.1.5-4.1.6

- Fix file recursion when looking for possible asset dependencies. Major preview server performance improvement.

## 4.1.4

- Unify default extensions for all URL processing extensions. #1855
- Fix URL regex for `content:` context of CSS. #1853
- Make sure CLI config over-rides `config.rb` order.
- Fix relative assets in some contexts. #1842

## 4.1.3

- Expose all top-level config options to CLI (flags now match config. latency -> watcher_latency, etc).
- Fix directory indexes with `.htm` and `.xhtml` files. #1821

## 4.1.2

- Add `page_id` concept. Using the `id` key in frontmatter, proxy or page will set an ID on a resource which can be referenced by `url_for` and `link_to`.
- Allow looking for `Gemfile` when setting up a project to fail gracefully.
- Send correct exit code when external_pipeline fails during build.
- Fix error when customizing `layouts_dir`. #1028
- Fix collections (commands in loops) not being processed by `page` command. #1226
- Correctly asset_hash sourcemap references.

## 4.1.1

- Fix bad code that made `/__middleman/` break.

## 4.1.0

- Add rewrite_ignore option to asset_hash, asset_host, cache_buster & relative_assets. This proc let's you opt-out of the extension behavior on a per-path basis.
- gzip extension now compresses svgs by default
- Fix the `encoding` option.
- Fix relative paths on `image_tag` helper.
- Correctly exit with error code on failed `init`
- Fixed `asset_hash` when path has query string or #hashes
- Fix new extension template
- Don't parse frontmatter on ignored files.
- Fix displaying frontmatter on `/__middleman/sitemap`
- Add `skip_build_clean` config which when set to a block, will avoid removing non-generated paths from build, like .git #1716
- Minor performance improvements
- DRY-up config.rb-specific commands like `ignore` or `path`.
- Fix automatic images with absolute (or images dir missing) paths in markdown. Fixes #1755
- Fix asset_host in combination with Google Analytics snippet. #1751
- Show an error message when git CLI is not available. #1765
- Correctly show file names of GZIP'ed assets. #1364
- Build file output is now parallel-ized! Use `middleman build --no-parallel` to disable.
- Make template file extensions that get layouts by default configurable via `config[:extensions_with_layout]`
- Remove `=` from inline url matcher. This means paths in HTML attributes MUST be quoted. Fixes #1780

## 4.0.0

- Add `:locales` and `:data` source types to the list of files which trigger a live-reload.
- Rename i18n `lang` and `langs` to `locale` and `locales`.
- Avoid matching URLs across new lines. #1689
- Load Middleman Directory when doing `init` over SSL
- Fix `external_pipeline` first runs running out of sequence.

## 4.0.0.rc.2

- Rather than applying layouts to all files which are not .txt, .css, .js, .json: the new behavior is to only default layouts to active for .html
- Switch from Ruby Sass to SassC.
- `relative_assets` extension overrides local `relative: false` option to stylesheet/javascript tag helpers.
- Add `before_server`-hook to the preview server which is run before the Webrick server is started
- Add `-d` to `middleman server` to make it run as daemon
- Trigger "Possible File Change" events on files which share an output or template type with a changed file. Allows LiveReload to update on partial changes.
- Added `import_file SOURCE, TARGET` and `import_path SOURCE_FOLDER` to copy resources from outside the project in. Does NOT do file change watching. Perfect for `bower_components`.

## 4.0.0.rc.1

- Removed ability to use JSON as frontmatter. Still allowed in data/ folder.
- Added YAML data postscript. Like frontmatter, but reversed. Attach content after the key/value data as a `:postscript` key to the data structure (if Hash).

## 4.0.0.beta.2

- Fixed regression causing exceptions to be silently thrown away outside of `--verbose` mode in the dev server.
- Pull in `--ssl` option from stable.
- Replace `hooks` gem with custom callback solution.

## 4.0.0.beta.1

- Add `resources` class method to extensions to allow simple string-based resource generation.
- rename `app.add_to_instance` to `Extension.expose_to_application` for adding extension-local methods to the shared app instance.
- rename `app.add_to_config_context` to `Extension.expose_to_config` for adding extension-local methods to the sandboxed scope of `config.rb`
- Add `Extension.expose_to_template`, which auto binds copies of extension-local methods into a Template context.
- Remove side-loading of CLI tasks from `tasks/`
- Add the option of naming `config.rb` as `middleman.rb`.
- Builder extracted from Thor. `after_build` hook now passes an instance of a Builder instead of the Thor CLI.
- New FileWatcher API.
- Remove the `partials_dir` setting. Partials should live next to content, or be addressed with absolute paths.
- Partials must be named with a leading underscore. `_my_snippet.html.erb`, not `my_snippet.html.erb`.
- Removed the `proxy` and `ignore` options for the `page` command in `config.rb`. Use the `proxy` and `ignore` commands instead of passing these options to `page`.
- The `page` command in `config.rb` can now be used to add data to the page via the `data` argument. It is accessed the same way as frontmatter data, via `current_resource.data`.
- Add support for `environments` with the `-e` CLI flag. Loads additional config from `environments/envname.rb`. Removed `development?` helper in favor of `environment?(:development)`. Added `server?` helper to differentiate between build and server mode.
- Removed `with_layout`. Use loops of `page` instead.
- Removed Queryable Sitemap API
- Removed `css_compressor` setting, use `activate :minify_css, :compressor =>` instead.
- Removed `js_compressor` setting, use `activate :minify_javascript, :compressor =>` instead.
- Removed ability to server folders of content statically (non-Middleman projects).
- Prevent local templates being loaded when \$HOME is not set
- Removed "Implied Extension feature"
- Remove 'upgrade' and 'install' CLI commands.
- Gemfile may be in a parent directory of your Middleman project root (where 'config.rb' is).
- All dependencies for your Middleman project must be expressed in `Gemfile` - Bundler is no longer optional.
- Asciidoc information now available with the `asciidoc` local, which is a normal hash.
- Remove `page` template local. Use `current_resource` instead.
- Dropped support for providing a block to `page` & `proxy`.
- Dropped support for instance variables inside templates.
- Moved all rendering into `TemplateRenderer` and `FileRenderer`
- Placed all template evaluation inside the `TemplateContext` class
- Remove deprecated `request` instance
- Remove old module-style extension support
- Placed all `config.rb` evaluation inside the `ConfigContext` class
- The preview server can now serve over HTTPS using the `--https` flag. It will use an automatic self-signed cert which can be overridden using `--ssl_certificate` and `--ssl_private_key`. These settings can also be set in `config.rb`
