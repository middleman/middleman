Write a comment here
*** Parameters: ***
{:on_error=>:raise}
*** Markdown input: ***

<img/>

<svg:svg/>

<svg:svg 
width="600px" height="400px">
  <svg:g id="group">
	<svg:circle id="circ1" r="1cm" cx="3cm" cy="3cm" style="fill:red;"></svg:circle>
	<svg:circle id="circ2" r="1cm" cx="7cm" cy="3cm" style="fill:red;" />
  </svg:g>
</svg:svg>

*** Output of inspect ***
md_el(:document,[
	md_html("<svg:svg/>"),
	md_html("<svg:svg \nwidth=\"600px\" height=\"400px\">\n  <svg:g id=\"group\">\n\t<svg:circle id=\"circ1\" r=\"1cm\" cx=\"3cm\" cy=\"3cm\" style=\"fill:red;\"></svg:circle>\n\t<svg:circle id=\"circ2\" r=\"1cm\" cx=\"7cm\" cy=\"3cm\" style=\"fill:red;\" />\n  </svg:g>\n</svg:svg>")
],{},[])
*** Output of to_html ***
<svg:svg /><svg:svg height='400px' width='600px'>
  <svg:g id='group'>
	<svg:circle cy='3cm' id='circ1' r='1cm' cx='3cm' style='fill:red;' />
	<svg:circle cy='3cm' id='circ2' r='1cm' cx='7cm' style='fill:red;' />
  </svg:g>
</svg:svg>
*** Output of to_latex ***

*** Output of to_md ***

*** Output of to_s ***

*** EOF ***




Failed tests:   [:inspect, :to_html] 

*** Output of inspect ***
-----| WARNING | -----
md_el(:document,[
	md_html("<img />"),
	md_html("<svg:svg/>"),
	md_html("<svg:svg \nwidth=\"600px\" height=\"400px\">\n  <svg:g id=\"group\">\n\t<svg:circle id=\"circ1\" r=\"1cm\" cx=\"3cm\" cy=\"3cm\" style=\"fill:red;\"></svg:circle>\n\t<svg:circle id=\"circ2\" r=\"1cm\" cx=\"7cm\" cy=\"3cm\" style=\"fill:red;\" />\n  </svg:g>\n</svg:svg>")
],{},[])
*** Output of to_html ***
-----| WARNING | -----
<img /><pre class='markdown-html-error' style='border: solid 3px red; background-color: pink'>REXML could not parse this XML/HTML: 
&lt;svg:svg/&gt;</pre><pre class='markdown-html-error' style='border: solid 3px red; background-color: pink'>REXML could not parse this XML/HTML: 
&lt;svg:svg 
width=&quot;600px&quot; height=&quot;400px&quot;&gt;
  &lt;svg:g id=&quot;group&quot;&gt;
	&lt;svg:circle id=&quot;circ1&quot; r=&quot;1cm&quot; cx=&quot;3cm&quot; cy=&quot;3cm&quot; style=&quot;fill:red;&quot;&gt;&lt;/svg:circle&gt;
	&lt;svg:circle id=&quot;circ2&quot; r=&quot;1cm&quot; cx=&quot;7cm&quot; cy=&quot;3cm&quot; style=&quot;fill:red;&quot; /&gt;
  &lt;/svg:g&gt;
&lt;/svg:svg&gt;</pre>
*** Output of to_latex ***

*** Output of to_md ***

*** Output of to_s ***

*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)