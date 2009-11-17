$:.unshift File.dirname(__FILE__) +"/../../lib"

require 'test/unit'
require 'syntax/lang/xml'

class TC_Syntax_XML < Test::Unit::TestCase

  def setup
    @xml = Syntax::XML.new
  end

  def test_empty
    called = false
    @xml.tokenize( "" ) { |tok| called = true }
    assert !called
  end

  def test_no_tag
    tok = []
    @xml.tokenize( "foo bar baz" ) { |t| tok << t }
    assert_equal [ :normal, "foo bar baz" ], [ tok.first.group, tok.shift ]
  end

  def test_entity_outside_tag
    tok = []
    @xml.tokenize( "&amp; &#10; &x157; &nosemi & foo;" ) { |t| tok << t }
    assert_equal [ :entity, "&amp;" ], [ tok.first.group, tok.shift ]
    tok.shift
    assert_equal [ :entity, "&#10;" ], [ tok.first.group, tok.shift ]
    tok.shift
    assert_equal [ :entity, "&x157;" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " &nosemi & foo;" ], [ tok.first.group, tok.shift ]
  end

  def test_start_tag
    tok = []
    @xml.tokenize( "<name" ) { |t| tok << t }
    assert_equal [ :punct, "<" ], [ tok.first.group, tok.shift ]
    assert_equal [ :tag, "name" ], [ tok.first.group, tok.shift ]
  end

  def test_start_xml_decl
    tok = []
    @xml.tokenize( "<?xml" ) { |t| tok << t }
    assert_equal [ :punct, "<?" ], [ tok.first.group, tok.shift ]
    assert_equal [ :tag, "xml" ], [ tok.first.group, tok.shift ]
  end

  def test_start_end_tag
    tok = []
    @xml.tokenize( "</name" ) { |t| tok << t }
    assert_equal [ :punct, "</" ], [ tok.first.group, tok.shift ]
    assert_equal [ :tag, "name" ], [ tok.first.group, tok.shift ]
  end

  def test_start_decl_tag
    tok = []
    @xml.tokenize( "<!name" ) { |t| tok << t }
    assert_equal [ :punct, "<!" ], [ tok.first.group, tok.shift ]
    assert_equal [ :tag, "name" ], [ tok.first.group, tok.shift ]
  end

  def test_start_confused
    tok = []
    @xml.tokenize( "<%name" ) { |t| tok << t }
    assert_equal [ :punct, "<%" ], [ tok.first.group, tok.shift ]
    assert_equal [ :attribute, "name" ], [ tok.first.group, tok.shift ]
  end

  def test_end_tag_out_of_context
    tok = []
    @xml.tokenize( "/>" ) { |t| tok << t }
    assert_equal [ :normal, "/>" ], [ tok.first.group, tok.shift ]
  end

  def test_start_namespaced_tag
    tok = []
    @xml.tokenize( "<foo:name" ) { |t| tok << t }
    assert_equal [ :punct, "<" ], [ tok.first.group, tok.shift ]
    assert_equal [ :namespace, "foo" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ":" ], [ tok.first.group, tok.shift ]
    assert_equal [ :tag, "name" ], [ tok.first.group, tok.shift ]
  end

  def test_attribute
    tok = []
    @xml.tokenize( "<name attr1 attr2" ) { |t| tok << t }
    assert_equal [ :punct, "<" ], [ tok.first.group, tok.shift ]
    assert_equal [ :tag, "name" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " " ], [ tok.first.group, tok.shift ]
    assert_equal [ :attribute, "attr1" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " " ], [ tok.first.group, tok.shift ]
    assert_equal [ :attribute, "attr2" ], [ tok.first.group, tok.shift ]
  end

  def test_namespaced_attribute
    tok = []
    @xml.tokenize( "<name foo:attr1 bar:attr2" ) { |t| tok << t }
    assert_equal [ :punct, "<" ], [ tok.first.group, tok.shift ]
    assert_equal [ :tag, "name" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " " ], [ tok.first.group, tok.shift ]
    assert_equal [ :namespace, "foo" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ":" ], [ tok.first.group, tok.shift ]
    assert_equal [ :attribute, "attr1" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " " ], [ tok.first.group, tok.shift ]
    assert_equal [ :namespace, "bar" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ":" ], [ tok.first.group, tok.shift ]
    assert_equal [ :attribute, "attr2" ], [ tok.first.group, tok.shift ]
  end

  def test_attribute_with_squote_value
    tok = []
    @xml.tokenize( "<name attr1='a value < > \\' here'" ) { |t| tok << t }
    assert_equal [ :punct, "<" ], [ tok.first.group, tok.shift ]
    assert_equal [ :tag, "name" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " " ], [ tok.first.group, tok.shift ]
    assert_equal [ :attribute, "attr1" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, "='" ], [ tok.first.group, tok.shift ]
    assert_equal [ :string, "a value < > \\' here" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, "'" ], [ tok.first.group, tok.shift ]
  end

  def test_attribute_with_dquote_value
    tok = []
    @xml.tokenize( '<name attr1="a value < > \" here"' ) { |t| tok << t }
    assert_equal [ :punct, "<" ], [ tok.first.group, tok.shift ]
    assert_equal [ :tag, "name" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " " ], [ tok.first.group, tok.shift ]
    assert_equal [ :attribute, "attr1" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, '="' ], [ tok.first.group, tok.shift ]
    assert_equal [ :string, 'a value < > \" here' ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, '"' ], [ tok.first.group, tok.shift ]
  end

  def test_entity_in_string
    tok = []
    @xml.tokenize( '<name "a &lt; value &gt;"' ) { |t| tok << t }
    assert_equal [ :punct, "<" ], [ tok.first.group, tok.shift ]
    assert_equal [ :tag, "name" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " " ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, '"' ], [ tok.first.group, tok.shift ]
    assert_equal [ :string, "a " ], [ tok.first.group, tok.shift ]
    assert_equal [ :entity, "&lt;" ], [ tok.first.group, tok.shift ]
    assert_equal [ :string, " value " ], [ tok.first.group, tok.shift ]
    assert_equal [ :entity, "&gt;" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, '"' ], [ tok.first.group, tok.shift ]
  end

  def test_number
    tok = []
    @xml.tokenize( '<name 5' ) { |t| tok << t }
    assert_equal [ :punct, "<" ], [ tok.first.group, tok.shift ]
    assert_equal [ :tag, "name" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " " ], [ tok.first.group, tok.shift ]
    assert_equal [ :number, "5" ], [ tok.first.group, tok.shift ]
  end

  def test_close_tag
    tok = []
    @xml.tokenize( '<name> foo' ) { |t| tok << t }
    assert_equal [ :punct, "<" ], [ tok.first.group, tok.shift ]
    assert_equal [ :tag, "name" ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, ">" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " foo" ], [ tok.first.group, tok.shift ]
  end

  def test_close_self_tag
    tok = []
    @xml.tokenize( '<name /> foo' ) { |t| tok << t }
    assert_equal [ :punct, "<" ], [ tok.first.group, tok.shift ]
    assert_equal [ :tag, "name" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " " ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, "/>" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " foo" ], [ tok.first.group, tok.shift ]
  end

  def test_close_decl_tag
    tok = []
    @xml.tokenize( '<?name ?> foo' ) { |t| tok << t }
    assert_equal [ :punct, "<?" ], [ tok.first.group, tok.shift ]
    assert_equal [ :tag, "name" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " " ], [ tok.first.group, tok.shift ]
    assert_equal [ :punct, "?>" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " foo" ], [ tok.first.group, tok.shift ]
  end

  def test_comment
    tok = []
    @xml.tokenize( "foo <!-- a comment\nspanning multiple\nlines --> bar" ) { |t| tok << t }
    assert_equal [ :normal, "foo " ], [ tok.first.group, tok.shift ]
    assert_equal [ :comment, "<!-- a comment\nspanning multiple\nlines -->" ], [ tok.first.group, tok.shift ]
    assert_equal [ :normal, " bar" ], [ tok.first.group, tok.shift ]
  end

  def test_comment_unterminated
    tok = []
    @xml.tokenize( "foo <!-- a comment\nspanning multiple\nlines -- bar" ) { |t| tok << t }
    assert_equal [ :normal, "foo " ], [ tok.first.group, tok.shift ]
    assert_equal [ :comment, "<!-- a comment\nspanning multiple\nlines -- bar" ], [ tok.first.group, tok.shift ]
  end

end
