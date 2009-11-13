# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{haml}
  s.version = "2.2.13"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nathan Weizenbaum", "Hampton Catlin"]
  s.date = %q{2009-11-09}
  s.description = %q{      Haml (HTML Abstraction Markup Language) is a layer on top of XHTML or XML
      that's designed to express the structure of XHTML or XML documents
      in a non-repetitive, elegant, easy way,
      using indentation rather than closing tags
      and allowing Ruby to be embedded with ease.
      It was originally envisioned as a plugin for Ruby on Rails,
      but it can function as a stand-alone templating engine.
}
  s.email = %q{haml@googlegroups.com}
  s.executables = ["haml", "html2haml", "sass", "css2sass"]
  s.extra_rdoc_files = ["VERSION_NAME", "CONTRIBUTING", "README.md", "MIT-LICENSE", "VERSION", "REVISION"]
  s.files = ["rails/init.rb", "lib/sass.rb", "lib/sass/css.rb", "lib/sass/script/node.rb", "lib/sass/script/number.rb", "lib/sass/script/operation.rb", "lib/sass/script/literal.rb", "lib/sass/script/functions.rb", "lib/sass/script/bool.rb", "lib/sass/script/color.rb", "lib/sass/script/lexer.rb", "lib/sass/script/parser.rb", "lib/sass/script/variable.rb", "lib/sass/script/string.rb", "lib/sass/script/funcall.rb", "lib/sass/script/unary_operation.rb", "lib/sass/script.rb", "lib/sass/error.rb", "lib/sass/repl.rb", "lib/sass/tree/comment_node.rb", "lib/sass/tree/node.rb", "lib/sass/tree/for_node.rb", "lib/sass/tree/debug_node.rb", "lib/sass/tree/import_node.rb", "lib/sass/tree/while_node.rb", "lib/sass/tree/mixin_def_node.rb", "lib/sass/tree/if_node.rb", "lib/sass/tree/mixin_node.rb", "lib/sass/tree/directive_node.rb", "lib/sass/tree/rule_node.rb", "lib/sass/tree/prop_node.rb", "lib/sass/tree/variable_node.rb", "lib/sass/plugin/rails.rb", "lib/sass/plugin/merb.rb", "lib/sass/environment.rb", "lib/sass/files.rb", "lib/sass/engine.rb", "lib/sass/plugin.rb", "lib/haml/filters.rb", "lib/haml/exec.rb", "lib/haml/error.rb", "lib/haml/template.rb", "lib/haml/shared.rb", "lib/haml/engine.rb", "lib/haml/version.rb", "lib/haml/template/patch.rb", "lib/haml/template/plugin.rb", "lib/haml/helpers.rb", "lib/haml/buffer.rb", "lib/haml/html.rb", "lib/haml/precompiler.rb", "lib/haml/util.rb", "lib/haml/helpers/action_view_mods.rb", "lib/haml/helpers/xss_mods.rb", "lib/haml/helpers/action_view_extensions.rb", "lib/haml.rb", "bin/sass", "bin/css2sass", "bin/html2haml", "bin/haml", "test/linked_rails.rb", "test/benchmark.rb", "test/sass/script_test.rb", "test/sass/css2sass_test.rb", "test/sass/results/units.css", "test/sass/results/parent_ref.css", "test/sass/results/compressed.css", "test/sass/results/complex.css", "test/sass/results/compact.css", "test/sass/results/mixins.css", "test/sass/results/line_numbers.css", "test/sass/results/alt.css", "test/sass/results/subdir/subdir.css", "test/sass/results/subdir/nested_subdir/nested_subdir.css", "test/sass/results/nested.css", "test/sass/results/import.css", "test/sass/results/multiline.css", "test/sass/results/script.css", "test/sass/results/basic.css", "test/sass/results/expanded.css", "test/sass/more_results/more_import.css", "test/sass/more_results/more1_with_line_comments.css", "test/sass/more_results/more1.css", "test/sass/templates/basic.sass", "test/sass/templates/bork.sass", "test/sass/templates/compressed.sass", "test/sass/templates/import.sass", "test/sass/templates/script.sass", "test/sass/templates/expanded.sass", "test/sass/templates/nested.sass", "test/sass/templates/_partial.sass", "test/sass/templates/line_numbers.sass", "test/sass/templates/compact.sass", "test/sass/templates/subdir/subdir.sass", "test/sass/templates/subdir/nested_subdir/nested_subdir.sass", "test/sass/templates/subdir/nested_subdir/_nested_partial.sass", "test/sass/templates/parent_ref.sass", "test/sass/templates/alt.sass", "test/sass/templates/importee.sass", "test/sass/templates/mixins.sass", "test/sass/templates/multiline.sass", "test/sass/templates/units.sass", "test/sass/templates/complex.sass", "test/sass/templates/bork2.sass", "test/sass/more_templates/_more_partial.sass", "test/sass/more_templates/more1.sass", "test/sass/more_templates/more_import.sass", "test/sass/functions_test.rb", "test/sass/engine_test.rb", "test/sass/plugin_test.rb", "test/haml/mocks/article.rb", "test/haml/rhtml/_av_partial_2.rhtml", "test/haml/rhtml/standard.rhtml", "test/haml/rhtml/_av_partial_1.rhtml", "test/haml/rhtml/action_view.rhtml", "test/haml/util_test.rb", "test/haml/spec/ruby_haml_test.rb", "test/haml/spec/README.md", "test/haml/spec/lua_haml_spec.lua", "test/haml/spec/tests.json", "test/haml/html2haml_test.rb", "test/haml/template_test.rb", "test/haml/helper_test.rb", "test/haml/results/tag_parsing.xhtml", "test/haml/results/content_for_layout.xhtml", "test/haml/results/helpers.xhtml", "test/haml/results/original_engine.xhtml", "test/haml/results/very_basic.xhtml", "test/haml/results/helpful.xhtml", "test/haml/results/list.xhtml", "test/haml/results/partials.xhtml", "test/haml/results/eval_suppressed.xhtml", "test/haml/results/nuke_inner_whitespace.xhtml", "test/haml/results/whitespace_handling.xhtml", "test/haml/results/render_layout.xhtml", "test/haml/results/silent_script.xhtml", "test/haml/results/standard.xhtml", "test/haml/results/just_stuff.xhtml", "test/haml/results/partial_layout.xhtml", "test/haml/results/filters.xhtml", "test/haml/results/nuke_outer_whitespace.xhtml", "test/haml/markaby/standard.mab", "test/haml/templates/tag_parsing.haml", "test/haml/templates/nuke_inner_whitespace.haml", "test/haml/templates/partial_layout.haml", "test/haml/templates/_av_partial_2_ugly.haml", "test/haml/templates/partials.haml", "test/haml/templates/_layout_for_partial.haml", "test/haml/templates/original_engine.haml", "test/haml/templates/helpers.haml", "test/haml/templates/_layout.erb", "test/haml/templates/action_view_ugly.haml", "test/haml/templates/content_for_layout.haml", "test/haml/templates/silent_script.haml", "test/haml/templates/very_basic.haml", "test/haml/templates/render_layout.haml", "test/haml/templates/filters.haml", "test/haml/templates/_av_partial_1.haml", "test/haml/templates/standard_ugly.haml", "test/haml/templates/_partial.haml", "test/haml/templates/nuke_outer_whitespace.haml", "test/haml/templates/breakage.haml", "test/haml/templates/list.haml", "test/haml/templates/standard.haml", "test/haml/templates/whitespace_handling.haml", "test/haml/templates/eval_suppressed.haml", "test/haml/templates/action_view.haml", "test/haml/templates/_av_partial_2.haml", "test/haml/templates/partialize.haml", "test/haml/templates/just_stuff.haml", "test/haml/templates/helpful.haml", "test/haml/templates/_av_partial_1_ugly.haml", "test/haml/templates/_text_area.haml", "test/haml/engine_test.rb", "test/test_helper.rb", "extra/haml-mode.el", "extra/sass-mode.el", "extra/update_watch.rb", "Rakefile", "init.rb", ".yardopts", "VERSION_NAME", "CONTRIBUTING", "README.md", "MIT-LICENSE", "VERSION", "REVISION"]
  s.homepage = %q{http://haml.hamptoncatlin.com/}
  s.rdoc_options = ["--title", "Haml", "--main", "README.rdoc", "--exclude", "lib/haml/buffer.rb", "--line-numbers", "--inline-source"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{haml}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{An elegant, structured XHTML/XML templating engine. Comes with Sass, a similar CSS templating engine.}
  s.test_files = ["test/sass/script_test.rb", "test/sass/css2sass_test.rb", "test/sass/functions_test.rb", "test/sass/engine_test.rb", "test/sass/plugin_test.rb", "test/haml/util_test.rb", "test/haml/spec/ruby_haml_test.rb", "test/haml/html2haml_test.rb", "test/haml/template_test.rb", "test/haml/helper_test.rb", "test/haml/engine_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<yard>, [">= 0.2.3"])
      s.add_development_dependency(%q<maruku>, [">= 0.5.9"])
    else
      s.add_dependency(%q<yard>, [">= 0.2.3"])
      s.add_dependency(%q<maruku>, [">= 0.5.9"])
    end
  else
    s.add_dependency(%q<yard>, [">= 0.2.3"])
    s.add_dependency(%q<maruku>, [">= 0.5.9"])
  end
end
