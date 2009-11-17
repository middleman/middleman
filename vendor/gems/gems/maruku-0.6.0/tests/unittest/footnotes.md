Write a comment abouth the test here.
*** Parameters: ***
{:footnotes_used=>["^b", "^c", "^a"]}
*** Markdown input: ***
That's some text with a footnote [^b] and another [^c] and another [^a].

[^a]: And that's the footnote.

    That's the second paragraph of the footnote.


[^b]: And that's the footnote.
This is second sentence (same paragraph).

[^c]:
    This is the very long one.

    That's the second paragraph.


This is not a footnote.
*** Output of inspect ***
md_el(:document,[
	md_par([
		"That",
		md_entity("rsquo"),
		"s some text with a footnote ",
		md_foot_ref("^b"),
		" and another ",
		md_foot_ref("^c"),
		" and another ",
		md_foot_ref("^a"),
		"."
	]),
	md_el(:footnote,[
		md_par(["And that", md_entity("rsquo"), "s the footnote."]),
		md_par([
			"That",
			md_entity("rsquo"),
			"s the second paragraph of the footnote."
		])
	],{:footnote_id=>"^a"},[]),
	md_el(:footnote,[
		md_par([
			"And that",
			md_entity("rsquo"),
			"s the footnote. This is second sentence (same paragraph)."
		])
	],{:footnote_id=>"^b"},[]),
	md_el(:footnote,[
		md_par(["This is the very long one."]),
		md_par(["That", md_entity("rsquo"), "s the second paragraph."])
	],{:footnote_id=>"^c"},[]),
	md_par(["This is not a footnote."])
],{},[])
*** Output of to_html ***
<p>That&#8217;s some text with a footnote <sup id='fnref:1'><a href='#fn:1' rel='footnote'>1</a></sup> and another <sup id='fnref:2'><a href='#fn:2' rel='footnote'>2</a></sup> and another <sup id='fnref:3'><a href='#fn:3' rel='footnote'>3</a></sup>.</p>

<p>This is not a footnote.</p>
<div class='footnotes'><hr /><ol><li id='fn:1'>
<p>And that&#8217;s the footnote. This is second sentence (same paragraph).</p>
<a href='#fnref:1' rev='footnote'>&#8617;</a></li><li id='fn:2'>
<p>This is the very long one.</p>

<p>That&#8217;s the second paragraph.</p>
<a href='#fnref:2' rev='footnote'>&#8617;</a></li><li id='fn:3'>
<p>And that&#8217;s the footnote.</p>

<p>That&#8217;s the second paragraph of the footnote.</p>
<a href='#fnref:3' rev='footnote'>&#8617;</a></li></ol></div>
*** Output of to_latex ***
That'{}s some text with a footnote \footnote{And that'{}s the footnote. This is second sentence (same paragraph).}  and another \footnote{This is the very long one.

That'{}s the second paragraph.}  and another \footnote{And that'{}s the footnote.

That'{}s the second paragraph of the footnote.} .

This is not a footnote.
*** Output of to_md ***
That s some text with a footnote and
another and another .

And that s the footnote.

That s the second paragraph of the
footnote.

And that s the footnote. This is second
sentence (same paragraph).

This is the very long one.

That s the second paragraph.

This is not a footnote.
*** Output of to_s ***
Thats some text with a footnote  and another  and another .And thats the footnote.Thats the second paragraph of the footnote.And thats the footnote. This is second sentence (same paragraph).This is the very long one.Thats the second paragraph.This is not a footnote.
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)