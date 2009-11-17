Write a comment here
*** Parameters: ***
{} # params 
*** Markdown input: ***
taking part in <a href="http://sied.dis.uniroma1.it/">some arcane conspirations</a> which
involve <b href="http://www.flickr.com/photos/censi/70893277/">coffee</b>, 
<a href="http://flickr.com/photos/censi/42775664/in/set-936677/">robots</a>,
<a href="http://www.flickr.com/photos/censi/42775888/in/set-936677/">sushi</a>,

*** Output of inspect ***
md_el(:document,[
	md_par([
		"taking part in ",
		md_html("<a href=\"http://sied.dis.uniroma1.it/\">some arcane conspirations</a>"),
		" which involve ",
		md_html("<b href=\"http://www.flickr.com/photos/censi/70893277/\">coffee</b>"),
		", ",
		md_html("<a href=\"http://flickr.com/photos/censi/42775664/in/set-936677/\">robots</a>"),
		", ",
		md_html("<a href=\"http://www.flickr.com/photos/censi/42775888/in/set-936677/\">sushi</a>"),
		","
	])
],{},[])
*** Output of to_html ***
<p>taking part in <a href='http://sied.dis.uniroma1.it/'>some arcane conspirations</a> which involve <b href='http://www.flickr.com/photos/censi/70893277/'>coffee</b>, <a href='http://flickr.com/photos/censi/42775664/in/set-936677/'>robots</a>, <a href='http://www.flickr.com/photos/censi/42775888/in/set-936677/'>sushi</a>,</p>
*** Output of to_latex ***
taking part in  which involve , , ,
*** Output of to_md ***
taking part in which involve , , ,
*** Output of to_s ***
taking part in  which involve , , ,
*** EOF ***



	OK!



*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)