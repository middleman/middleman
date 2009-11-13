require 'stringio'
require 'rubygems'
require 'minitest/unit'
require 'rdoc/ri/formatter'
require 'rdoc/markup/fragments'
require 'rdoc/markup/to_flow'

class TestRDocRIHtmlFormatter < MiniTest::Unit::TestCase

  def setup
    @output = StringIO.new
    @width = 78
    @indent = '  '

    @f = RDoc::RI::HtmlFormatter.new @output, @width, @indent
    @markup = RDoc::Markup.new
    @flow = RDoc::Markup::ToFlow.new
    @af = RDoc::RI::AttributeFormatter
  end

  def test_blankline
    @f.blankline

    assert_equal "<p />\n", @output.string
  end

  def test_bold_print
    @f.bold_print 'text'

    assert_equal '<b>text</b>', @output.string
  end

  def test_break_to_newline
    @f.break_to_newline

    assert_equal "<br />\n", @output.string
  end

  def test_display_heading
    @f.display_heading 'text', 1, '  '

    assert_equal "<h1>text</h1>\n", @output.string
  end

  def test_display_heading_level_4
    @f.display_heading 'text', 4, '  '

    assert_equal "<h4>text</h4>\n", @output.string
  end

  def test_display_heading_level_5
    @f.display_heading 'text', 5, '  '

    assert_equal "<h4>text</h4>\n", @output.string
  end

  def test_display_list_bullet
    list = RDoc::Markup::Flow::LIST.new :BULLET
    list << RDoc::Markup::Flow::LI.new(nil, 'a b c')
    list << RDoc::Markup::Flow::LI.new(nil, 'd e f')

    @f.display_list list

    expected = <<-EOF.strip
<ul><li>a b c<p />
</li><li>d e f<p />
</li></ul>
    EOF

    assert_equal expected, @output.string
  end

  def test_display_list_number
    list = RDoc::Markup::Flow::LIST.new :NUMBER
    list << RDoc::Markup::Flow::LI.new(nil, 'a b c')
    list << RDoc::Markup::Flow::LI.new(nil, 'd e f')

    @f.display_list list

    expected = <<-EOF.strip
<ol><li>a b c<p />
</li><li>d e f<p />
</li></ol>
    EOF

    assert_equal expected, @output.string
  end

  def test_display_list_labeled
    list = RDoc::Markup::Flow::LIST.new :LABELED
    list << RDoc::Markup::Flow::LI.new('label',   'a b c')
    list << RDoc::Markup::Flow::LI.new('label 2', 'd e f')

    @f.display_list list

    expected = <<-EOF.strip
<dl><dt><b>label</b></dt><dd>a b c<p />
</dd><dt><b>label 2</b></dt><dd>d e f<p />
</dd></dl>
    EOF

    assert_equal expected, @output.string
  end

  def test_display_list_note
    list = RDoc::Markup::Flow::LIST.new :NOTE
    list << RDoc::Markup::Flow::LI.new('note:',   'a b c')
    list << RDoc::Markup::Flow::LI.new('note 2:', 'd e f')

    @f.display_list list

    expected = <<-EOF.strip
<table><tr valign="top"><td>note:</td><td>a b c<p />
</td></tr><tr valign="top"><td>note&nbsp;2:</td><td>d e f<p />
</td></tr></table>
    EOF

    assert_equal expected, @output.string
  end

  def test_display_verbatim_flow_item
    verbatim = RDoc::Markup::Flow::VERB.new '*a* > b &gt; c'
    @f.display_verbatim_flow_item verbatim

    assert_equal "<pre>*a* &gt; b &amp;gt; c\n</pre>\n", @output.string
  end

  def test_draw_line
    @f.draw_line

    assert_equal "<hr />\n", @output.string
  end

  def test_draw_line_label
    @f.draw_line 'label'

    assert_equal "<b>label</b><hr />\n", @output.string
  end

end

