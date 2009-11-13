require 'rubygems'
require 'minitest/unit'
require 'rdoc/markup'
require 'rdoc/markup/to_html'

class TestRDocMarkupToHtml < MiniTest::Unit::TestCase

  def setup
    @m = RDoc::Markup.new
    @am = RDoc::Markup::AttributeManager.new
    @th = RDoc::Markup::ToHtml.new
  end

  def test_class_gen_relative_url
    def gen(from, to)
      RDoc::Markup::ToHtml.gen_relative_url from, to
    end

    assert_equal 'a.html',    gen('a.html',   'a.html')
    assert_equal 'b.html',    gen('a.html',   'b.html')

    assert_equal 'd.html',    gen('a/c.html', 'a/d.html')
    assert_equal '../a.html', gen('a/c.html', 'a.html')
    assert_equal 'a/c.html',  gen('a.html',   'a/c.html')
  end

  def test_list_verbatim
    str = "* one\n    verb1\n    verb2\n* two\n"

    expected = <<-EXPECTED
<ul>
<li>one

<pre>
  verb1
  verb2
</pre>
</li>
<li>two

</li>
</ul>
    EXPECTED

    assert_equal expected, @m.convert(str, @th)
  end

  def test_tt_formatting
    assert_equal "<p>\n<tt>--</tt> &#8212; <tt>cats'</tt> cats&#8217;\n</p>\n",
                 util_format("<tt>--</tt> -- <tt>cats'</tt> cats'")

    assert_equal "<p>\n<b>&#8212;</b>\n</p>\n", util_format("<b>--</b>")
  end

  def test_convert_string_fancy
    #
    # The HTML typesetting is broken in a number of ways, but I have fixed
    # the most glaring issues for single and double quotes.  Note that
    # "strange" symbols (periods or dashes) need to be at the end of the
    # test case strings in order to suppress cross-references.
    #
    assert_equal "<p>\n&#8220;cats&#8221;.\n</p>\n", util_format("\"cats\".")
    assert_equal "<p>\n&#8216;cats&#8217;.\n</p>\n", util_format("\'cats\'.")
    assert_equal "<p>\ncat&#8217;s-\n</p>\n", util_format("cat\'s-")
  end

  def util_fragment(text)
    RDoc::Markup::Fragment.new 0, nil, nil, text
  end

  def util_format(text)
    fragment = util_fragment text

    @th.start_accepting
    @th.accept_paragraph @am, fragment
    @th.end_accepting
  end

end

MiniTest::Unit.autorun
