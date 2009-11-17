Write a comment here
*** Parameters: ***
{} # params 
*** Markdown input: ***
Here is a paragraph.


   * Item 1
   * Item 2
   * Item 3

*** Output of inspect ***
md_el(:document,[
	md_par(["Here is a paragraph."]),
	md_el(:ul,[
		md_el(:li_span,["Item 1"],{:want_my_paragraph=>false},[]),
		md_el(:li_span,["Item 2"],{:want_my_paragraph=>false},[]),
		md_el(:li_span,["Item 3"],{:want_my_paragraph=>false},[])
	],{},[])
],{},[])
*** Output of to_html ***
<p>Here is a paragraph.</p>

<ul>
<li>Item 1</li>

<li>Item 2</li>

<li>Item 3</li>
</ul>
*** Output of to_latex ***
Here is a paragraph.

* Item 1 * Item 2 * Item 3
*** Output of to_md ***
Here is a paragraph.

-tem 1
-tem 2
-tem 3
*** Output of to_s ***
Here is a paragraph.Item 1Item 2Item 3
*** EOF ***




Failed tests:   [:inspect, :to_html, :to_md, :to_s] 

*** Output of inspect ***
-----| WARNING | -----
md_el(:document,[
	md_par(["Here is a paragraph."]),
	md_par(["* Item 1 * Item 2 * Item 3"])
],{},[])
*** Output of to_html ***
-----| WARNING | -----
<p>Here is a paragraph.</p>

<p>* Item 1 * Item 2 * Item 3</p>
*** Output of to_latex ***
Here is a paragraph.

* Item 1 * Item 2 * Item 3
*** Output of to_md ***
-----| WARNING | -----
Here is a paragraph.

* Item 1 * Item 2 * Item 3
*** Output of to_s ***
-----| WARNING | -----
Here is a paragraph.* Item 1 * Item 2 * Item 3
*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)