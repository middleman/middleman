$:.unshift File.dirname(__FILE__) +"/../../lib"

require 'test/unit'
require 'syntax/lang/yaml'

class TC_Syntax_YAML < Test::Unit::TestCase

  def setup
    @yaml = Syntax::YAML.new
  end

  def test_empty
    called = false
    @yaml.tokenize( "" ) { |tok| called = true }
    assert !called
  end

  def test_doc_notype
    tok = []
    @yaml.tokenize( "---\n" ) { |t| tok << t }
    assert_equal [ :document, "---" ], [ tok.first.group, tok.shift ]
  end

  def test_doc_type
    tok = []
    @yaml.tokenize( "--- !foo/bar/^type \n" ) { |t| tok << t }
    assert_equal [ :document, "--- !foo/bar/^type " ], [ tok.first.group, tok.shift ]
  end

  def test_key_no_indent
    tok = []
    @yaml.tokenize( "foo : bar" ) { |t| tok << t }
    assert_equal [ :key, "foo" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " " ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ":" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " bar" ], [ tok.first.group, tok.shift ]
  end

  def test_key_indent
    tok = []
    @yaml.tokenize( "  foo : bar" ) { |t| tok << t }
    assert_equal [ :normal, "  " ], [ tok.first.group, tok.shift ]
    assert_equal [ :key, "foo" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " " ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ":" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " bar" ], [ tok.first.group, tok.shift ]
  end

  def test_key_quoted
    tok = []
    @yaml.tokenize( "  'foo' : bar" ) { |t| tok << t }
    assert_equal [ :normal, "  " ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, "'" ], [ tok.first.group, tok.shift ]
    assert_equal [ :string, "foo" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, "'" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " " ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ":" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " bar" ], [ tok.first.group, tok.shift ]
  end

  def test_key_no_value
    tok = []
    @yaml.tokenize( "  foo: \n  bar:\n" ) { |t| tok << t }
    assert_equal [ :normal, "  " ], [ tok.first.group, tok.shift ]
    assert_equal [ :key, "foo" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ":" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " \n  " ], [ tok.first.group, tok.shift ]
    assert_equal [ :key, "bar" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ":" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, "\n" ], [ tok.first.group, tok.shift ]
  end

  def test_list_no_indent
    tok = []
    @yaml.tokenize( "- bar" ) { |t| tok << t }
    assert_equal [ :punct, "-" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " bar" ], [ tok.first.group, tok.shift ]
  end

  def test_list_indent
    tok = []
    @yaml.tokenize( "  - bar" ) { |t| tok << t }
    assert_equal [ :normal, "  " ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, "-" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " bar" ], [ tok.first.group, tok.shift ]
  end

  def test_blank_lines
    tok = []
    @yaml.tokenize( "foo: bar\n\n\nbaz: bang" ) { |t| tok << t }
    assert_equal [ :key, "foo" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ":" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " bar\n\n\n" ], [ tok.first.group, tok.shift ]
    assert_equal [ :key, "baz" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ":" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " bang" ], [ tok.first.group, tok.shift ]
  end

  def test_type
    tok = []
    @yaml.tokenize( "  - !name/space^type\n    - foo" ) { |t| tok << t }
    assert_equal [ :normal, "  " ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, "-" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " " ], [ tok.first.group, tok.shift ]
    assert_equal [ :type, "!name/space^type" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, "\n    " ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, "-" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " foo" ], [ tok.first.group, tok.shift ]
  end

  def test_anchor_ref
    tok = []
    @yaml.tokenize( "foo: &blah\nbar: *blah" ) { |t| tok << t }
    assert_equal [ :key, "foo" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ":" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " " ], [ tok.first.group, tok.shift ]
    assert_equal [ :anchor, "&blah" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, "\n" ], [ tok.first.group, tok.shift ]
    assert_equal [ :key, "bar" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ":" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " " ], [ tok.first.group, tok.shift ]
    assert_equal [ :ref, "*blah" ], [ tok.first.group, tok.shift ]
  end

  def test_time
    tok = []
    @yaml.tokenize( "foo: 01:23:45\n" ) { |t| tok << t }
    assert_equal [ :key, "foo" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ":" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " " ], [ tok.first.group, tok.shift ]
    assert_equal [ :time, "01:23:45" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, "\n" ], [ tok.first.group, tok.shift ]
  end

  def test_date
    tok = []
    @yaml.tokenize( "foo: 1234-56-78 01:23:45.123456 +01:23\n" ) { |t| tok << t }
    assert_equal [ :key, "foo" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ":" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " " ], [ tok.first.group, tok.shift ]
    assert_equal [ :date, "1234-56-78 01:23:45.123456 +01:23" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, "\n" ], [ tok.first.group, tok.shift ]
  end

  def test_string_dquote
    tok = []
    @yaml.tokenize( 'foo: "this is a \"string\""' ) { |t| tok << t }
    assert_equal [ :key, "foo" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ":" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " " ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, '"' ], [ tok.first.group, tok.shift ]
    assert_equal [ :string, 'this is a ' ], [ tok.first.group, tok.shift ]
    assert_equal [ :expr, '\"' ], [ tok.first.group, tok.shift ]
    assert_equal [ :string, 'string' ], [ tok.first.group, tok.shift ]
    assert_equal [ :expr, '\"' ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, '"' ], [ tok.first.group, tok.shift ]
  end

  def test_string_squote
    tok = []
    @yaml.tokenize( "foo: 'this is a \\\"string\\\"'" ) { |t| tok << t }
    assert_equal [ :key, "foo" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ":" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " " ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, "'" ], [ tok.first.group, tok.shift ]
    assert_equal [ :string, 'this is a \"string\"' ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, "'" ], [ tok.first.group, tok.shift ]
  end

  def test_symbol
    tok = []
    @yaml.tokenize( "  :foo: 'this is a \\\"string\\\"'" ) { |t| tok << t }
    assert_equal [ :normal, "  " ], [ tok.first.group, tok.shift ]
    assert_equal [ :symbol, ":foo" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ":" ], [ tok.first.group, tok.shift ]
  end

  def test_comment
    tok = []
    @yaml.tokenize( "foo: a value # comment\n# another comment: foo\n" ) { |t| tok << t }
    assert_equal [ :key, "foo" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ":" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " a value " ], [ tok.first.group, tok.shift ]
    assert_equal [ :comment, "# comment" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, "\n" ], [ tok.first.group, tok.shift ]
    assert_equal [ :comment, "# another comment: foo" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, "\n" ], [ tok.first.group, tok.shift ]
  end

  def test_long_text
    tok = []
    text = <<EOF
foo: >-
  a b c d
  e f g

  h i


  j k l
  m n

bar: baz
EOF
    @yaml.tokenize( text ) { |t| tok << t }
    assert_equal [ :key, "foo" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ":" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " " ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ">-" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, "\n" ], [ tok.first.group, tok.shift ]
    assert_equal [ :string, "  a b c d\n  e f g\n\n  h i\n\n\n  j k l\n  m n\n\n" ], [ tok.first.group, tok.shift ]
    assert_equal [ :key, "bar" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ":" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " baz\n" ], [ tok.first.group, tok.shift ]
  end

  def test_long_test_at_eof
    tok = []
    @yaml.tokenize( "foo: >\n  one two\n  three four" ) { |t| tok << t }
    assert_equal [ :key, "foo" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ":" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " " ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ">" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, "\n" ], [ tok.first.group, tok.shift ]
    assert_equal [ :string, "  one two\n  three four" ], [ tok.first.group, tok.shift ]
  end

end
