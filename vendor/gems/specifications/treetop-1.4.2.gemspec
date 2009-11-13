# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{treetop}
  s.version = "1.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nathan Sobo"]
  s.autorequire = %q{treetop}
  s.date = %q{2009-09-10}
  s.default_executable = %q{tt}
  s.email = %q{nathansobo@gmail.com}
  s.executables = ["tt"]
  s.files = ["LICENSE", "README.md", "Rakefile", "lib/treetop/bootstrap_gen_1_metagrammar.rb", "lib/treetop/compiler/grammar_compiler.rb", "lib/treetop/compiler/lexical_address_space.rb", "lib/treetop/compiler/metagrammar.rb", "lib/treetop/compiler/metagrammar.treetop", "lib/treetop/compiler/node_classes/anything_symbol.rb", "lib/treetop/compiler/node_classes/atomic_expression.rb", "lib/treetop/compiler/node_classes/character_class.rb", "lib/treetop/compiler/node_classes/choice.rb", "lib/treetop/compiler/node_classes/declaration_sequence.rb", "lib/treetop/compiler/node_classes/grammar.rb", "lib/treetop/compiler/node_classes/inline_module.rb", "lib/treetop/compiler/node_classes/nonterminal.rb", "lib/treetop/compiler/node_classes/optional.rb", "lib/treetop/compiler/node_classes/parenthesized_expression.rb", "lib/treetop/compiler/node_classes/parsing_expression.rb", "lib/treetop/compiler/node_classes/parsing_rule.rb", "lib/treetop/compiler/node_classes/predicate.rb", "lib/treetop/compiler/node_classes/predicate_block.rb", "lib/treetop/compiler/node_classes/repetition.rb", "lib/treetop/compiler/node_classes/sequence.rb", "lib/treetop/compiler/node_classes/terminal.rb", "lib/treetop/compiler/node_classes/transient_prefix.rb", "lib/treetop/compiler/node_classes/treetop_file.rb", "lib/treetop/compiler/node_classes.rb", "lib/treetop/compiler/ruby_builder.rb", "lib/treetop/compiler.rb", "lib/treetop/ruby_extensions/string.rb", "lib/treetop/ruby_extensions.rb", "lib/treetop/runtime/compiled_parser.rb", "lib/treetop/runtime/interval_skip_list/head_node.rb", "lib/treetop/runtime/interval_skip_list/interval_skip_list.rb", "lib/treetop/runtime/interval_skip_list/node.rb", "lib/treetop/runtime/interval_skip_list.rb", "lib/treetop/runtime/syntax_node.rb", "lib/treetop/runtime/terminal_parse_failure.rb", "lib/treetop/runtime/terminal_parse_failure_debug.rb", "lib/treetop/runtime/terminal_syntax_node.rb", "lib/treetop/runtime.rb", "lib/treetop/version.rb", "lib/treetop.rb", "bin/tt", "doc/contributing_and_planned_features.markdown", "doc/grammar_composition.markdown", "doc/index.markdown", "doc/pitfalls_and_advanced_techniques.markdown", "doc/semantic_interpretation.markdown", "doc/site.rb", "doc/sitegen.rb", "doc/syntactic_recognition.markdown", "doc/using_in_ruby.markdown", "examples/lambda_calculus/arithmetic.rb", "examples/lambda_calculus/arithmetic.treetop", "examples/lambda_calculus/arithmetic_node_classes.rb", "examples/lambda_calculus/arithmetic_test.rb", "examples/lambda_calculus/lambda_calculus", "examples/lambda_calculus/lambda_calculus.rb", "examples/lambda_calculus/lambda_calculus.treetop", "examples/lambda_calculus/lambda_calculus_node_classes.rb", "examples/lambda_calculus/lambda_calculus_test.rb", "examples/lambda_calculus/test_helper.rb"]
  s.homepage = %q{http://functionalform.blogspot.com}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A Ruby-based text parsing and interpretation DSL}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<polyglot>, [">= 0.2.5"])
    else
      s.add_dependency(%q<polyglot>, [">= 0.2.5"])
    end
  else
    s.add_dependency(%q<polyglot>, [">= 0.2.5"])
  end
end
