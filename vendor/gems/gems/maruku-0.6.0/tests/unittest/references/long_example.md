Taken from the syntax document
*** Parameters: ***
{}
*** Markdown input: ***

filters -- including [Setext] [1], [atx] [2], [Textile] [3], [reStructuredText] [4],
[Grutatext] [5], and [EtText] [6] -- the single biggest source of
inspiration for Markdown's syntax is the format of plain text email.

  [1]: http://docutils.sourceforge.net/mirror/setext.html
  [2]: http://www.aaronsw.com/2002/atx/
  [3]: http://textism.com/tools/textile/
  [4]: http://docutils.sourceforge.net/rst.html
  [5]: http://www.triptico.com/software/grutatxt.html
  [6]: http://ettext.taint.org/doc/

To this end, Markdown's syntax is comprised entirely of punctuation
*** Output of inspect ***
md_el(:document,[
	md_par([
		"filters ",
		md_entity("ndash"),
		" including ",
		md_link(["Setext"],"1"),
		", ",
		md_link(["atx"],"2"),
		", ",
		md_link(["Textile"],"3"),
		", ",
		md_link(["reStructuredText"],"4"),
		", ",
		md_link(["Grutatext"],"5"),
		", and ",
		md_link(["EtText"],"6"),
		" ",
		md_entity("ndash"),
		" the single biggest source of inspiration for Markdown",
		md_entity("rsquo"),
		"s syntax is the format of plain text email."
	]),
	md_ref_def("1", "http://docutils.sourceforge.net/mirror/setext.html", {:title=>nil}),
	md_ref_def("2", "http://www.aaronsw.com/2002/atx/", {:title=>nil}),
	md_ref_def("3", "http://textism.com/tools/textile/", {:title=>nil}),
	md_ref_def("4", "http://docutils.sourceforge.net/rst.html", {:title=>nil}),
	md_ref_def("5", "http://www.triptico.com/software/grutatxt.html", {:title=>nil}),
	md_ref_def("6", "http://ettext.taint.org/doc/", {:title=>nil}),
	md_par([
		"To this end, Markdown",
		md_entity("rsquo"),
		"s syntax is comprised entirely of punctuation"
	])
],{},[])
*** Output of to_html ***
<p>filters &#8211; including <a href='http://docutils.sourceforge.net/mirror/setext.html'>Setext</a>, <a href='http://www.aaronsw.com/2002/atx/'>atx</a>, <a href='http://textism.com/tools/textile/'>Textile</a>, <a href='http://docutils.sourceforge.net/rst.html'>reStructuredText</a>, <a href='http://www.triptico.com/software/grutatxt.html'>Grutatext</a>, and <a href='http://ettext.taint.org/doc/'>EtText</a> &#8211; the single biggest source of inspiration for Markdown&#8217;s syntax is the format of plain text email.</p>

<p>To this end, Markdown&#8217;s syntax is comprised entirely of punctuation</p>
*** Output of to_latex ***
filters --{} including \href{http://docutils.sourceforge.net/mirror/setext.html}{Setext}, \href{http://www.aaronsw.com/2002/atx/}{atx}, \href{http://textism.com/tools/textile/}{Textile}, \href{http://docutils.sourceforge.net/rst.html}{reStructuredText}, \href{http://www.triptico.com/software/grutatxt.html}{Grutatext}, and \href{http://ettext.taint.org/doc/}{EtText} --{} the single biggest source of inspiration for Markdown'{}s syntax is the format of plain text email.

To this end, Markdown'{}s syntax is comprised entirely of punctuation
*** Output of to_md ***
filters including Setext, atx, Textile,
reStructuredText, Grutatext, and EtText
the single biggest source of
inspiration for Markdown s syntax is
the format of plain text email.

To this end, Markdown s syntax is
comprised entirely of punctuation
*** Output of to_s ***
filters  including Setext, atx, Textile, reStructuredText, Grutatext, and EtText  the single biggest source of inspiration for Markdowns syntax is the format of plain text email.To this end, Markdowns syntax is comprised entirely of punctuation
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)