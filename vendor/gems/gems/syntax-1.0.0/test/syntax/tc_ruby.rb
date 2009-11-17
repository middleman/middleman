require File.dirname(__FILE__) + "/tokenizer_testcase"

class TC_Syntax_Ruby < TokenizerTestCase

  syntax "ruby"

  def test_empty
    tokenize ""
    assert_no_next_token
  end

  def test_constant
    tokenize "Foo"
    assert_next_token :constant, "Foo"
  end

  def test_ident
    tokenize "foo"
    assert_next_token :ident, "foo"
  end

  def test_comment_eol
    tokenize "# a comment\nfoo"
    assert_next_token :comment, "# a comment"
    assert_next_token :normal, "\n"
    assert_next_token :ident, "foo"
  end

  def test_comment_block
    tokenize "=begin\nthis is a comment\n=end\nnoncomment"
    assert_next_token :comment, "=begin\nthis is a comment\n=end"
    assert_next_token :normal, "\n"
    assert_next_token :ident, "noncomment"
  end

  def test_comment_block_with_CRNL
    tokenize "=begin\r\nthis is a comment\r\n=end\r\nnoncomment"
    assert_next_token :comment, "=begin\r\nthis is a comment\r\n=end"
    assert_next_token :normal, "\r\n"
    assert_next_token :ident, "noncomment"
  end

  def test_keyword
    Syntax::Ruby::KEYWORDS.each do |word|
      tokenize word
      assert_next_token :keyword, word
    end
    Syntax::Ruby::KEYWORDS.each do |word|
      tokenize "foo.#{word}"
      skip_token 2
      assert_next_token :ident, word
    end
  end

  def test__END__
    tokenize "__END__\n\nblah blah blah"
    assert_next_token :comment, "__END__\n\nblah blah blah"
  end

  def test__END__with_CRNL
    tokenize "__END__\r\nblah blah blah"
    assert_next_token :comment, "__END__\r\nblah blah blah"
  end

  def test_def_paren
    tokenize "def  foo(bar)"
    assert_next_token :keyword, "def  "
    assert_next_token :method, "foo"
    assert_next_token :punct, "("
    assert_next_token :ident, "bar"
    assert_next_token :punct, ")"
  end

  def test_def_space
    tokenize "def  foo bar"
    assert_next_token :keyword, "def  "
    assert_next_token :method, "foo"
    assert_next_token :normal, " "
    assert_next_token :ident, "bar"
  end

  def test_def_semicolon
    tokenize "def  foo;"
    assert_next_token :keyword, "def  "
    assert_next_token :method, "foo"
    assert_next_token :punct, ";"
  end

  def test_def_eol
    tokenize "def foo"
    assert_next_token :keyword, "def "
    assert_next_token :method, "foo"
  end

  def test_class_space
    tokenize "class    Foo\n"
    assert_next_token :keyword, "class    "
    assert_next_token :class, "Foo"
    assert_next_token :normal, "\n"
  end

  def test_class_semicolon
    tokenize "class    Foo;"
    assert_next_token :keyword, "class    "
    assert_next_token :class, "Foo"
    assert_next_token :punct, ";"
  end

  def test_class_extend
    tokenize "class    Foo< Bang"
    assert_next_token :keyword, "class    "
    assert_next_token :class, "Foo"
    assert_next_token :punct, "<"
    assert_next_token :normal, " "
    assert_next_token :constant, "Bang"
  end

  def test_module_space
    tokenize "module    Foo\n"
    assert_next_token :keyword, "module    "
    assert_next_token :module, "Foo"
    assert_next_token :normal, "\n"
  end

  def test_module_semicolon
    tokenize "module    Foo;"
    assert_next_token :keyword, "module    "
    assert_next_token :module, "Foo"
    assert_next_token :punct, ";"
  end

  def test_module_other
    tokenize "module    Foo!\n"
    assert_next_token :keyword, "module    "
    assert_next_token :module, "Foo!"
  end

  def test_scope_operator
    tokenize "Foo::Bar"
    assert_next_token :constant, "Foo"
    assert_next_token :punct, "::"
    assert_next_token :constant, "Bar"
  end

  def test_symbol_dquote
    tokenize ':"foo"'
    assert_next_token :symbol, ':"'
    assert_next_token :symbol, '', :region_open
    assert_next_token :symbol, 'foo'
    assert_next_token :symbol, '', :region_close
    assert_next_token :symbol, '"'
    assert_no_next_token
  end

  def test_symbol_squote
    tokenize ":'foo'"
    assert_next_token :symbol, ":'"
    assert_next_token :symbol, "", :region_open
    assert_next_token :symbol, "foo"
    assert_next_token :symbol, "", :region_close
    assert_next_token :symbol, "'"
    assert_no_next_token
  end

  def test_symbol
    tokenize ":foo_123"
    assert_next_token :symbol, ":foo_123"

    tokenize ":123"
    assert_next_token :punct, ":"
    assert_next_token :number, "123"

    tokenize ":foo="
    assert_next_token :symbol, ":foo="

    tokenize ":foo!"
    assert_next_token :symbol, ":foo!"

    tokenize ":foo?"
    assert_next_token :symbol, ":foo?"
  end

  def test_char
    tokenize "?."
    assert_next_token :char, "?."

    tokenize '?\n'
    assert_next_token :char, '?\n'
  end

  def test_specials
    %w{__FILE__ __LINE__ true false nil self}.each do |word|
      tokenize word
      assert_next_token :constant, word
    end

    %w{__FILE__ __LINE__ true false nil self}.each do |word|
      tokenize "#{word}?"
      assert_next_token :ident, "#{word}?"
    end

    %w{__FILE__ __LINE__ true false nil self}.each do |word|
      tokenize "#{word}!"
      assert_next_token :ident, "#{word}!"
    end

    %w{__FILE__ __LINE__ true false nil self}.each do |word|
      tokenize "x.#{word}"
      skip_token 2
      assert_next_token :ident, word
    end
  end

  def test_pct_r
    tokenize '%r{foo#{x}bar}'
    assert_next_token :punct, "%r{"
    assert_next_token :regex, "", :region_open
    assert_next_token :regex, "foo"
    assert_next_token :expr, '#{x}'
    assert_next_token :regex, "bar"
    assert_next_token :regex, "", :region_close
    assert_next_token :punct, "}"

    tokenize '%r-foo#{x}bar-'
    assert_next_token :punct, "%r-"
    assert_next_token :regex, "", :region_open
    assert_next_token :regex, "foo"
    assert_next_token :expr, '#{x}'
    assert_next_token :regex, "bar"
    assert_next_token :regex, "", :region_close
    assert_next_token :punct, "-"
  end

  def test_pct_r_with_wakas
    tokenize '%r<foo#{x}bar> foo'
    assert_next_token :punct, "%r<"
    assert_next_token :regex, "", :region_open
    assert_next_token :regex, "foo"
    assert_next_token :expr, '#{x}'
    assert_next_token :regex, "bar"
    assert_next_token :regex, "", :region_close
    assert_next_token :punct, ">"
    assert_next_token :normal, " "
    assert_next_token :ident, "foo"
  end

  def test_pct_w_brace
    tokenize '%w{foo bar baz}'
    assert_next_token :punct, "%w{"
    assert_next_token :string, '', :region_open
    assert_next_token :string, 'foo bar baz'
    assert_next_token :string, '', :region_close
    assert_next_token :punct, "}"
  end

  def test_pct_w
    tokenize '%w-foo#{x} bar baz-'
    assert_next_token :punct, "%w-"
    assert_next_token :string, '', :region_open
    assert_next_token :string, 'foo#{x} bar baz'
    assert_next_token :string, '', :region_close
    assert_next_token :punct, "-"
  end

  def test_pct_q
    tokenize '%q-hello #{world}-'
    assert_next_token :punct, "%q-"
    assert_next_token :string, '', :region_open
    assert_next_token :string, 'hello #{world}'
    assert_next_token :string, '', :region_close
    assert_next_token :punct, "-"
  end
 
  def test_pct_s
    tokenize '%s-hello #{world}-'
    assert_next_token :punct, "%s-"
    assert_next_token :symbol, '', :region_open
    assert_next_token :symbol, 'hello #{world}'
    assert_next_token :symbol, '', :region_close
    assert_next_token :punct, "-"
  end

  def test_pct_W
    tokenize '%W-foo#{x} bar baz-'
    assert_next_token :punct, "%W-"
    assert_next_token :string, '', :region_open
    assert_next_token :string, 'foo'
    assert_next_token :expr, '#{x}'
    assert_next_token :string, ' bar baz'
    assert_next_token :string, '', :region_close
    assert_next_token :punct, "-"
  end

  def test_pct_Q
    tokenize '%Q-hello #{world}-'
    assert_next_token :punct, "%Q-"
    assert_next_token :string, '', :region_open
    assert_next_token :string, 'hello '
    assert_next_token :expr, '#{world}'
    assert_next_token :string, '', :region_close
    assert_next_token :punct, "-"
  end

  def test_pct_x
    tokenize '%x-ls /blah/#{foo}-'
    assert_next_token :punct, "%x-"
    assert_next_token :string, '', :region_open
    assert_next_token :string, 'ls /blah/'
    assert_next_token :expr, '#{foo}'
    assert_next_token :string, '', :region_close
    assert_next_token :punct, "-"
  end

  def test_pct_string
    tokenize '%-hello #{world}-'
    assert_next_token :punct, "%-"
    assert_next_token :string, '', :region_open
    assert_next_token :string, 'hello '
    assert_next_token :expr, '#{world}'
    assert_next_token :string, '', :region_close
    assert_next_token :punct, "-"
  end

  def test_bad_pct_string
    tokenize '%0hello #{world}0'
    assert_next_token :punct, "%"
    assert_next_token :number, '0'
    assert_next_token :ident, 'hello'
    assert_next_token :normal, ' '
    assert_next_token :comment, '#{world}0'
  end

  def test_shift_left
    tokenize 'foo << 5'
    assert_next_token :ident, "foo"
    assert_next_token :normal, " "
    assert_next_token :punct, "<<"
    assert_next_token :normal, " "
    assert_next_token :number, "5"
  end

  def test_shift_left_no_white
    tokenize 'foo<<5'
    assert_next_token :ident, "foo"
    assert_next_token :punct, "<<"
    assert_next_token :number, "5"
  end

  def test_here_doc_no_opts
    tokenize "foo <<EOF\n  foo\n  bar\n  baz\nEOF"
    assert_next_token :ident, "foo"
    assert_next_token :normal, " "
    assert_next_token :punct, "<<"
    assert_next_token :constant, "EOF"
    assert_next_token :string, "", :region_open
    assert_next_token :string, "\n  foo\n  bar\n  baz\n"
    assert_next_token :string, "", :region_close
    assert_next_token :constant, "EOF"
  end

  def test_here_doc_no_opts_missing_end
    tokenize "foo <<EOF\n  foo\n  bar\n  baz\n EOF"
    assert_next_token :ident, "foo"
    assert_next_token :normal, " "
    assert_next_token :punct, "<<"
    assert_next_token :constant, "EOF"
    assert_next_token :string, "", :region_open
    assert_next_token :string, "\n  foo\n  bar\n  baz\n EOF"
    assert_no_next_token
  end

  def test_here_doc_float_right
    tokenize "foo <<-EOF\n  foo\n  bar\n  baz\n  EOF"
    assert_next_token :ident, "foo"
    assert_next_token :normal, " "
    assert_next_token :punct, "<<-"
    assert_next_token :constant, "EOF"
    assert_next_token :string, "", :region_open
    assert_next_token :string, "\n  foo\n  bar\n  baz\n"
    assert_next_token :string, "", :region_close
    assert_next_token :constant, "  EOF"
  end

  def test_here_doc_single_quotes
    tokenize "foo <<'EOF'\n  foo\#{x}\n  bar\n  baz\nEOF"
    assert_next_token :ident, "foo"
    assert_next_token :normal, " "
    assert_next_token :punct, "<<'"
    assert_next_token :constant, "EOF"
    assert_next_token :punct, "'"
    assert_next_token :string, "", :region_open
    assert_next_token :string, "\n  foo\#{x}\n  bar\n  baz\n"
    assert_next_token :string, "", :region_close
    assert_next_token :constant, "EOF"
  end

  def test_here_doc_double_quotes
    tokenize "foo <<\"EOF\"\n  foo\#{x}\n  bar\n  baz\nEOF"
    assert_next_token :ident, "foo"
    assert_next_token :normal, " "
    assert_next_token :punct, "<<\""
    assert_next_token :constant, "EOF"
    assert_next_token :punct, "\""
    assert_next_token :string, "", :region_open
    assert_next_token :string, "\n  foo"
    assert_next_token :expr, '#{x}'
    assert_next_token :string, "\n  bar\n  baz\n"
    assert_next_token :string, "", :region_close
    assert_next_token :constant, "EOF"
  end

  def test_space
    tokenize "\n  \t\t\n\n\r\n"
    assert_next_token :normal, "\n  \t\t\n\n\r\n"
  end

  def test_number
    tokenize "1 1.0 1e5 1.0e5 1_2.5 1_2.5_2 1_2.5_2e3_2"
    assert_next_token :number, "1"
    skip_token
    assert_next_token :number, "1.0"
    skip_token
    assert_next_token :number, "1e5"
    skip_token
    assert_next_token :number, "1.0e5"
    skip_token
    assert_next_token :number, "1_2.5"
    skip_token
    assert_next_token :number, "1_2.5_2"
    skip_token
    assert_next_token :number, "1_2.5_2e3_2"
  end

  def test_dquoted_string
    tokenize '"foo #{x} bar\"\n\tbaz\xA5b\5\1234"'
    assert_next_token :punct, '"'
    assert_next_token :string, '', :region_open
    assert_next_token :string, 'foo '
    assert_next_token :expr, '#{x}'
    assert_next_token :string, ' bar'
    assert_next_token :escape, '\"\n\t'
    assert_next_token :string, 'baz'
    assert_next_token :escape, '\xA5'
    assert_next_token :string, 'b'
    assert_next_token :escape, '\5\123'
    assert_next_token :string, '4'
    assert_next_token :string, '', :region_close
    assert_next_token :punct, '"'
  end

  def test_squoted_string
    tokenize '\'foo #{x} bar\\\'\n\tbaz\\\\\xA5b\5\1234\''
    assert_next_token :punct, "'"
    assert_next_token :string, "", :region_open
    assert_next_token :string, 'foo #{x} bar'
    assert_next_token :escape, '\\\''
    assert_next_token :string, '\n\tbaz'
    assert_next_token :escape, '\\\\'
    assert_next_token :string, '\xA5b\5\1234'
    assert_next_token :string, "", :region_close
    assert_next_token :punct, "'"
  end

  def test_dot_selector
    tokenize 'foo.nil'
    skip_token
    assert_next_token :punct, "."
    assert_next_token :ident, "nil"
  end

  def test_dot_range_inclusive
    tokenize 'foo..nil'
    skip_token
    assert_next_token :punct, ".."
    assert_next_token :constant, "nil"
  end

  def test_dot_range_exclusive
    tokenize 'foo...nil'
    skip_token
    assert_next_token :punct, "..."
    assert_next_token :constant, "nil"
  end

  def test_dot_range_many
    tokenize 'foo.....nil'
    skip_token
    assert_next_token :punct, "....."
    assert_next_token :constant, "nil"
  end

  def test_attribute
    tokenize '@var_foo'
    assert_next_token :attribute, "@var_foo"
  end

  def test_global
    tokenize '$var_foo'
    assert_next_token :global, "$var_foo"
    tokenize '$12'
    assert_next_token :global, "$12"
    tokenize '$/f'
    assert_next_token :global, "$/"
    tokenize "$\n"
    assert_next_token :global, "$"
  end

  def test_paren_delimiter
    tokenize '%w(a)'
    assert_next_token :punct, "%w("
    assert_next_token :string, "", :region_open
    assert_next_token :string, "a"
    assert_next_token :string, "", :region_close
    assert_next_token :punct, ")"
  end

  def test_division
    tokenize 'm / 3'
    assert_next_token :ident, "m"
    assert_next_token :normal, " "
    assert_next_token :punct, "/"
    assert_next_token :normal, " "
    assert_next_token :number, "3"
  end

  def test_regex
    tokenize 'm =~ /3/'
    assert_next_token :ident, "m"
    assert_next_token :normal, " "
    assert_next_token :punct, "=~"
    assert_next_token :normal, " "
    assert_next_token :punct, "/"
    assert_next_token :regex, "", :region_open
    assert_next_token :regex, "3"
    assert_next_token :regex, "", :region_close
    assert_next_token :punct, "/"
  end

  def test_heredoc_with_trailing_text
    tokenize "foo('here', <<EOF)\n  A heredoc.\nEOF\nfoo"
    assert_next_token :ident,  "foo"
    assert_next_token :punct,  "('"
    assert_next_token :string, '', :region_open
    assert_next_token :string, 'here'
    assert_next_token :string, '', :region_close
    assert_next_token :punct,  "',"
    assert_next_token :normal, ' '
    assert_next_token :punct,  '<<'
    assert_next_token :constant, "EOF"
    assert_next_token :punct,  ')'
    assert_next_token :string, "", :region_open
    assert_next_token :string, "\n  A heredoc.\n"
    assert_next_token :string, "", :region_close
    assert_next_token :constant, "EOF"
    assert_next_token :normal, "\n"
    assert_next_token :ident,  "foo"
  end

  def test_multiple_heredocs
    tokenize <<'TEST'
foo('here', <<EOF, 'there', <<-'FOO', 'blah')
First heredoc, right here.
Expressions are #{allowed}
EOF
    Another heredoc, immediately after the first.
    Expressions are not #{allowed}
  FOO
TEST
    assert_next_token :ident,  "foo"
    assert_next_token :punct,  "('"
    assert_next_token :string, '', :region_open
    assert_next_token :string, 'here'
    assert_next_token :string, '', :region_close
    assert_next_token :punct,  "',"
    assert_next_token :normal, ' '
    assert_next_token :punct,  '<<'
    assert_next_token :constant, "EOF"
    assert_next_token :punct,  ','
    assert_next_token :normal, ' '
    assert_next_token :punct,  "'"
    assert_next_token :string, '', :region_open
    assert_next_token :string, 'there'
    assert_next_token :string, '', :region_close
    assert_next_token :punct,  "',"
    assert_next_token :normal, ' '
    assert_next_token :punct,  "<<-'"
    assert_next_token :constant, "FOO"
    assert_next_token :punct,  "',"
    assert_next_token :normal, ' '
    assert_next_token :punct,  "'"
    assert_next_token :string, '', :region_open
    assert_next_token :string, 'blah'
    assert_next_token :string, '', :region_close
    assert_next_token :punct,  "')"
    assert_next_token :string, "", :region_open
    assert_next_token :string, "\nFirst heredoc, right here.\nExpressions are "
    assert_next_token :expr, '#{allowed}'
    assert_next_token :string, "\n"
    assert_next_token :string, "", :region_close
    assert_next_token :constant, "EOF"
    assert_next_token :string, "", :region_open
    assert_next_token :string, "\n    Another heredoc, immediately after the first.\n    Expressions are not \#{allowed}\n"
    assert_next_token :string, "", :region_close
    assert_next_token :constant, "  FOO"
  end

  def test_carldr_bad_heredoc_001
    tokenize <<'TEST'
str = <<END
here document #{1 + 1}
END

if str
TEST

    assert_next_token :ident, "str"
    assert_next_token :normal, " "
    assert_next_token :punct, "="
    assert_next_token :normal, " "
    assert_next_token :punct, "<<"
    assert_next_token :constant, "END"
    assert_next_token :string, "", :region_open
    assert_next_token :string, "\nhere document "
    assert_next_token :expr, '#{1 + 1}'
    assert_next_token :string, "\n"
    assert_next_token :string, "", :region_close
    assert_next_token :constant, "END"
    assert_next_token :normal, "\n\n"
    assert_next_token :keyword, "if"
    assert_next_token :normal, " "
    assert_next_token :ident, "str"
  end

  def test_regex_after_keyword
    tokenize "when /[0-7]/\nfoo"
    assert_next_token :keyword, "when"
    assert_next_token :normal, " "
    assert_next_token :punct, "/"
    assert_next_token :regex, "", :region_open
    assert_next_token :regex, "[0-7]"
    assert_next_token :regex, "", :region_close
    assert_next_token :punct, "/"
    assert_next_token :normal, "\n"
    assert_next_token :ident, "foo"
  end

  def test_heredoc_after_lparen
    tokenize "foo(<<SRC, obj)\nblah blah\nSRC\nfoo"
    assert_next_token :ident, "foo"
    assert_next_token :punct, "(<<"
    assert_next_token :constant, "SRC"
    assert_next_token :punct, ","
    assert_next_token :normal, " "
    assert_next_token :ident, "obj"
    assert_next_token :punct, ")"
    assert_next_token :string, "", :region_open
    assert_next_token :string, "\nblah blah\n"
    assert_next_token :string, "", :region_close
    assert_next_token :constant, "SRC"
    assert_next_token :normal, "\n"
    assert_next_token :ident, "foo"
  end

  def test_division_after_parens
    tokenize "(a+b)/2"
    assert_next_token :punct, "("
    assert_next_token :ident, "a"
    assert_next_token :punct, "+"
    assert_next_token :ident, "b"
    assert_next_token :punct, ")/"
    assert_next_token :number, "2"
  end

  def test_heredoc_with_CRNL
    tokenize "foo <<SRC\r\nSome text\r\nSRC\r\nfoo"
    assert_next_token :ident, "foo"
    assert_next_token :normal, " "
    assert_next_token :punct, "<<"
    assert_next_token :constant, "SRC"
    assert_next_token :string, "", :region_open
    assert_next_token :string, "\r\nSome text\r\n"
    assert_next_token :string, "", :region_close
    assert_next_token :constant, "SRC"
    assert_next_token :normal, "\r\n"
    assert_next_token :ident, "foo"
  end

  def test_question_mark_at_newline
    tokenize "foo ?\n 'bar': 'baz'"
    assert_next_token :ident, "foo"
    assert_next_token :normal, " "
    assert_next_token :punct, "?"
    assert_next_token :normal, "\n "
    assert_next_token :punct, "'"
    assert_next_token :string, "", :region_open
    assert_next_token :string, "bar"
    assert_next_token :string, "", :region_close
    assert_next_token :punct, "':"
    assert_next_token :normal, " "
    assert_next_token :punct, "'"
    assert_next_token :string, "", :region_open
    assert_next_token :string, "baz"
    assert_next_token :string, "", :region_close
    assert_next_token :punct, "'"
  end

  def test_question_mark_and_escaped_newline
    tokenize "foo ?\\\n 'bar': 'baz'"
    assert_next_token :ident, "foo"
    assert_next_token :normal, " "
    assert_next_token :punct, "?\\"
    assert_next_token :normal, "\n "
    assert_next_token :punct, "'"
    assert_next_token :string, "", :region_open
    assert_next_token :string, "bar"
    assert_next_token :string, "", :region_close
    assert_next_token :punct, "':"
    assert_next_token :normal, " "
    assert_next_token :punct, "'"
    assert_next_token :string, "", :region_open
    assert_next_token :string, "baz"
    assert_next_token :string, "", :region_close
    assert_next_token :punct, "'"
  end

  def test_highlighted_subexpression
    tokenizer.set :expressions => :highlight
    tokenize '"la la #{["hello", "world"].each { |f| puts "string #{f}" }}"'
    assert_next_token :punct, '"'
    assert_next_token :string, "", :region_open
    assert_next_token :string, "la la "
    assert_next_token :expr, "", :region_open
    assert_next_token :expr, '#{'
    assert_next_token :punct, '["'
    assert_next_token :string, "", :region_open
    assert_next_token :string, 'hello'
    assert_next_token :string, "", :region_close
    assert_next_token :punct, '",'
    assert_next_token :normal, ' '
    assert_next_token :punct, '"'
    assert_next_token :string, "", :region_open
    assert_next_token :string, "world"
    assert_next_token :string, "", :region_close
    assert_next_token :punct, '"].'
    assert_next_token :ident, 'each'
    assert_next_token :normal, ' '
    assert_next_token :punct, '{'
    assert_next_token :normal, ' '
    assert_next_token :punct, '|'
    assert_next_token :ident, 'f'
    assert_next_token :punct, '|'
    assert_next_token :normal, ' '
    assert_next_token :ident, 'puts'
    assert_next_token :normal, ' '
    assert_next_token :punct, '"'
    assert_next_token :string, "", :region_open
    assert_next_token :string, "string "
    assert_next_token :expr, "", :region_open
    assert_next_token :expr, '#{'
    assert_next_token :ident, 'f'
    assert_next_token :expr, '}'
    assert_next_token :expr, "", :region_close
    assert_next_token :string, "", :region_close
    assert_next_token :punct, '"'
    assert_next_token :normal, ' '
    assert_next_token :punct, '}'
    assert_next_token :expr, '}'
    assert_next_token :expr, "", :region_close
    assert_next_token :string, "", :region_close
    assert_next_token :punct, '"'
  end

  def test_expr_in_braces
    tokenize '"#{f}"'
    assert_next_token :punct, '"'
    assert_next_token :string, "", :region_open
    assert_next_token :expr, '#{f}'
    assert_next_token :string, "", :region_close
    assert_next_token :punct, '"'
  end

  def test_expr_in_braces_with_nested_braces
    tokenize '"#{loop{break}}"'
    assert_next_token :punct, '"'
    assert_next_token :string, "", :region_open
    assert_next_token :expr, '#{loop{break}}'
    assert_next_token :string, "", :region_close
    assert_next_token :punct, '"'
  end

  def test_expr_with_global_var
    tokenize '"#$f"'
    assert_next_token :punct, '"'
    assert_next_token :string, "", :region_open
    assert_next_token :expr, '#$f'
    assert_next_token :string, "", :region_close
    assert_next_token :punct, '"'
  end

  def test_expr_with_instance_var
    tokenize '"#@f"'
    assert_next_token :punct, '"'
    assert_next_token :string, "", :region_open
    assert_next_token :expr, '#@f'
    assert_next_token :string, "", :region_close
    assert_next_token :punct, '"'
  end

  def test_expr_with_class_var
    tokenize '"#@@f"'
    assert_next_token :punct, '"'
    assert_next_token :string, "", :region_open
    assert_next_token :expr, '#@@f'
    assert_next_token :string, "", :region_close
    assert_next_token :punct, '"'
  end

  def test_qmark_space
    tokenize "? "
    assert_next_token :punct, "?"
    assert_next_token :normal, " "
  end

  def test_capitalized_method
    tokenize "obj.Foo"
    skip_token 2
    assert_next_token :ident, "Foo"
  end

  def test_hexadecimal_literal
    tokenize "0xDEADbeef 0X1234567890ABCDEFG"
    assert_next_token :number, "0xDEADbeef"
    skip_token
    assert_next_token :number, "0X1234567890ABCDEF"
    assert_next_token :constant, "G"
  end

  def test_binary_literal
    tokenize "0b2 0b0 0b101 0B123"
    assert_next_token :number, "0"
    assert_next_token :ident, "b2"
    skip_token
    assert_next_token :number, "0b0"
    skip_token
    assert_next_token :number, "0b101"
    skip_token
    assert_next_token :number, "0B123"
  end

  def test_octal_literal
    tokenize "0o9 0o12345670abc 0O12345678"
    assert_next_token :number, "0"
    assert_next_token :ident, "o9"
    skip_token
    assert_next_token :number, "0o12345670"
    assert_next_token :ident, "abc"
    skip_token
    assert_next_token :number, "0O12345678"
  end

  def test_decimal_literal
    tokenize "0dA 0d1234567890abc 0D1234567890"
    assert_next_token :number, "0"
    assert_next_token :ident, "dA"
    skip_token
    assert_next_token :number, "0d1234567890"
    assert_next_token :ident, "abc"
    skip_token
    assert_next_token :number, "0D1234567890"
  end
end
