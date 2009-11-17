Write a comment here
*** Parameters: ***
{} # params 
*** Markdown input: ***

WebKit (Safari 3.1) and the CSS @font-face declaration
======================================================
 
I'm a big fan of typography in general. If you check out [my homepage](http://elliottcable.name) or my [contact elliottcable](http://elliottcable.name/contact.xhtml) page, and you're using Safari/WebKit or Opera/Kestrel, you'll notice the typefaces (fonts, as colloquialized) are *very* non-standard. (As of this writing, I'm using [Museo][] and [Diavlo][][^jos] heavily on both.)
 
The internet has not be a friendly place for typohiles like myself, up to this point, at least. One might even say it was a frightful, mentally scarring environment for those akin to yours truly. We've been restricted to reading page after page after page on day after day after day for year after year after year abominations of markup and design enslaved by the horrible overlords we know as Lucida, Verdana, Arial, Helvetica, Geneva, Georgia, Courier, and... dare I invoke ye, thou my terrible overlord? Times New Roman.
 
Wherefore art thou, my glorious Archer? And thee as well, my beautiful Garamond? The technical restrictions of that horrible monster we know as the Web Browser hath forced us all too long to use those most banal, those most common, and those most abused, out of all of the typefaces of the world.
 
All hyperbole aside, I'm extremely happy to see the advent of a standard `@font-face` declaration in CSS. Internet Explorer first implemented a crutched, basic version of this way back in version 4, but nothing ever really came of it - their decision to create the proprietary .EOT[^eot] format to appease overly restrictive type foundries' worries about intellectual property (aka. the cold, hard dominatrix that we know only as Ms. Profit) truly and completely killed that initial attempt at bringing astute typography and it's advocates to the web. This new run at `@font-face` by an established, trusted, and open group (the [W3C][] itself, responsible for helping to make much of what we use as designers on the web standard and cross-system compatible) has a much better chance, in my humble opinion - and I am quite looking forward to the consequences if it succeeds.
 
Now, onwards to the topic of my post as declared in the header (yes, I know, a slow start - but it's an interesting topic with an interesting history!). WebKit, the open source rendering engine behind the wonderfulness that is Safari, and how it handles the 'new' `@font-face` declaration. No, it's not really 'new', but yes, it feels like it is.
 
To put it simply, and to be very blunt, it's broken.
 
The [CSS spec section][spec] for `@font-face` is very specific - typefaces are to be selected based on a wide array of criteria placed in the `@font-face` declaration block itself. Various textual CSS attributes may be defined within the `@font-face` declaration, and then they will be checked when the typeface is referred to later in the CSS. For instance, if I have two `@font-face` declarations for the Diavlo family - one for regular text, and one for a heavier weighted version of the typeface - then I later utilize Diavlo in a `font-family:` attribute, it should refer to the basic Diavlo font defined in the first `@font-face`. However, if I were to do the same, but also specify a heavy `font-weight:`, then it should use the heavier version of Diavlo. To place this example in code:
 
    @font-face {
      font-family: 'Diavlo';
      src: url(./Diavlo/Diavlo_Book.otf) format("opentype");
    }
    
    @font-face {
      font-family: 'Diavlo';
      font-weight: 900;
      src: url(./Diavlo/Diavlo_Black.otf) format("opentype");
    }
    
    h1, h2, h3, h4, h5, h6 {
      font-family: 'Diavlo';
      font-weight: 900;
    }
    
    div#content {
      font-family: 'Diavlo';
    }
 
As you can see, my headings should use the typeface defined in `Diavlo_Black.otf`, while my body content should use `Diavlo_Book.otf`. However, in WebKit, this doesn't work - it completely ignores any attribute except `font-family:` and `src:` in a `@font-face` declaration! Completely ignores them! Not only that - not *only* that - it disregards all but the last `@font-face` for a given `font-family:` attribute string!
 
The implication here is that, to make `@font-face` work as it is currently implemented in WebKit (and thus, Safari 3.1), I have to declare *completely imaginary, non-existent type families* to satisfy WebKit alone. Here's the method I have used in the places I current implement `@font-face`:
 
    @font-face {
      font-family: 'Diavlo Book';
      src: url(./Diavlo/Diavlo_Book.otf) format("opentype");
    }
    
    @font-face {
      font-family: 'Diavlo Black';
      src: url(./Diavlo/Diavlo_Black.otf) format("opentype");
    }
    
    h1, h2, h3, h4, h5, h6 {
      font-family: 'Diavlo Black';
    }
    
    div#content {
      font-family: 'Diavlo Book';
    }
 
Isn't it horrible? Seriously, my eyes, they bleed. There's lots of problems with this far beyond the lack of semanticity when it comes to the typeface names... let me see how many ways this breaks the purpose of `@font-face`:
 
 - You remove a large element our control over the display of the page.
 
    As soon as we begin to use `@font-face` in our page, we can no longer make any use of any other textual control attribute - `font-weight:`, `font-style:`, and `font-variant:` are no longer available to us, because they no longer correctly map to technical typeface variant/features.
    
    Also, many default elements are destroyed, unusable, without 'fixing' - for instance, `<b>` would have no effect in a page styled for WebKit as above; We would have to specify something like `b {font-family: 'Diavlo Black';}` - how broken is that? Unless we caught all such default elements and re-styled them to use the bastardized names instead of the correct attributes, lots of basic HTML formatting would be broken. I myself may never use in-document formatting (separation of design and content!), but what about comments forms? Forum posts? Direct HTML-literal quotes?
    
    If we want to use Javascript to modify the display of the content, we can't simply adjust the mentioned textual control attributes - we have to know and change the entire `font-family:` array of strings.
 
 - You make us very wet.
 
     And by wet, I mean 'not DRY'. What if we decide to change one of the bastardized font names? Or use a different font entirely? We have to go through all of our CSS, all of our Javascript, and make sure we update every occurrence of the typeface's bastardized name.
 
 - You remove our user's user choice, and waste bandwidth.
 
    Since the names refer to families that don't, in fact, exist, the browser can't override the declaration with a user's installed version of the typeface. This means that, regardless of whether the user already has the typeface installed on their own computer, the browser won't use that - it doesn't know to use 'Diavlo', which the user has installed, because it was told to use 'Diavlo Black', which no user in the entire world has installed on their computer.
 
This whole thing is rather worrying - I've heard Opera has `@font-face` support, though I haven't had time to test this myself, so I don't know if it actually does - or, for that matter, if it does it 'correctly', or has the same problems as WebKit. But either way, WebKit is one of the first two implementations to ever attempt to support `@font-face` (Microsoft's unrelated `@font-face` declaration notwithstanding) - I really don't want to see it's early mistakes carried on to FireFox in a few years, and then Internet Explorer a few decades after that. That will leave us stuck with this broken system forever, as it has been demonstrated time and time again that if nobody else supports an old standard correctly, a newcomer to the standard will not do it correctly either. I for one would really, really, hate that.
 
In summary... come on, WebKit team, this isn't like you - you're always the ones with the closest-to-standard implementation, and the cleanest code, and... hell, overall? Webkit is the most secure/fastest browser available. But this is making me lose my faith in you, guys, please get it right. You're pioneering a leap into the future when it comes to the Web - this is as important, or _more_ important, than Mosiac's allowing of images was.
 
To put it succinctly - don't fuck this up, y'all.
 
[Museo]: <http://www.josbuivenga.demon.nl/museo.html> (Jos Buivenga's Museo free typeface)
[Diavlo]: <http://www.josbuivenga.demon.nl/diavlo.html> (Jos Buivenga's free Diavlo typeface)
[^jos]: These are fonts by [Jos Buivenga][jos], quite the amazing person. His (free) fonts are, uniquely, released for use on the web in `@font-face` declarations - unlike the vast majority of other (even free to download) typefaces, which have ridiculously restricting licenses and terms of use statements. Props, Jos - you're a pioneer, and deserve recognition as such.
*[CSS]: Cascading Style Sheets
*[.EOT]: Embedded OpenType
[^eot]: To give Microsoft a little credit, something I rarely do... Yes, I'm aware Microsoft submitted EOT to the W3C as a proposal - the problem isn't with their attempts to make it non-proprietary, but with the basic concept of making typefaces on the web DRMed. Look what such attempts have done to the music and video industry - simply decimated it. Do we really want to see the same thing happen to our beloved medium as typography moves into the 21st century?
*[W3C]: World Wide Web Consortium
[W3C]: <http://w3c.org> (World Wide Web Consortium)
[spec]: <http://?> ()
*[DRY]: Don't Repeat Yourself
[jos]: jos

*** Output of inspect ***
md_el(:document,[
	md_el(:header,["WebKit (Safari 3.1) and the CSS @font-face declaration"],{:level=>1},[]),
	md_par([
		"I",
		md_entity("rsquo"),
		"m a big fan of typography in general. If you check out ",
		md_im_link(["my homepage"], "http://elliottcable.name", nil),
		" or my ",
		md_im_link(["contact elliottcable"], "http://elliottcable.name/contact.xhtml", nil),
		" page, and you",
		md_entity("rsquo"),
		"re using Safari/WebKit or Opera/Kestrel, you",
		md_entity("rsquo"),
		"ll notice the typefaces (fonts, as colloquialized) are ",
		md_em(["very"]),
		" non-standard. (As of this writing, I",
		md_entity("rsquo"),
		"m using ",
		md_link(["Museo"],"museo"),
		" and ",
		md_link(["Diavlo"],"diavlo"),
		md_foot_ref("^jos"),
		" heavily on both.)"
	]),
	md_par([
		"The internet has not be a friendly place for typohiles like myself, up to this point, at least. One might even say it was a frightful, mentally scarring environment for those akin to yours truly. We",
		md_entity("rsquo"),
		"ve been restricted to reading page after page after page on day after day after day for year after year after year abominations of markup and design enslaved by the horrible overlords we know as Lucida, Verdana, Arial, Helvetica, Geneva, Georgia, Courier, and",
		md_entity("hellip"),
		" dare I invoke ye, thou my terrible overlord? Times New Roman."
	]),
	md_par([
		"Wherefore art thou, my glorious Archer? And thee as well, my beautiful Garamond? The technical restrictions of that horrible monster we know as the Web Browser hath forced us all too long to use those most banal, those most common, and those most abused, out of all of the typefaces of the world."
	]),
	md_par([
		"All hyperbole aside, I",
		md_entity("rsquo"),
		"m extremely happy to see the advent of a standard ",
		md_code("@font-face"),
		" declaration in CSS. Internet Explorer first implemented a crutched, basic version of this way back in version 4, but nothing ever really came of it - their decision to create the proprietary .EOT",
		md_foot_ref("^eot"),
		" format to appease overly restrictive type foundries",
		md_entity("rsquo"),
		" worries about intellectual property (aka. the cold, hard dominatrix that we know only as Ms. Profit) truly and completely killed that initial attempt at bringing astute typography and it",
		md_entity("rsquo"),
		"s advocates to the web. This new run at ",
		md_code("@font-face"),
		" by an established, trusted, and open group (the ",
		md_link(["W3C"],"w3c"),
		" itself, responsible for helping to make much of what we use as designers on the web standard and cross-system compatible) has a much better chance, in my humble opinion - and I am quite looking forward to the consequences if it succeeds."
	]),
	md_par([
		"Now, onwards to the topic of my post as declared in the header (yes, I know, a slow start - but it",
		md_entity("rsquo"),
		"s an interesting topic with an interesting history!). WebKit, the open source rendering engine behind the wonderfulness that is Safari, and how it handles the ",
		md_entity("lsquo"),
		"new",
		md_entity("rsquo"),
		" ",
		md_code("@font-face"),
		" declaration. No, it",
		md_entity("rsquo"),
		"s not really ",
		md_entity("lsquo"),
		"new",
		md_entity("rsquo"),
		", but yes, it feels like it is."
	]),
	md_par([
		"To put it simply, and to be very blunt, it",
		md_entity("rsquo"),
		"s broken."
	]),
	md_par([
		"The ",
		md_link(["CSS spec section"],"spec"),
		" for ",
		md_code("@font-face"),
		" is very specific - typefaces are to be selected based on a wide array of criteria placed in the ",
		md_code("@font-face"),
		" declaration block itself. Various textual CSS attributes may be defined within the ",
		md_code("@font-face"),
		" declaration, and then they will be checked when the typeface is referred to later in the CSS. For instance, if I have two ",
		md_code("@font-face"),
		" declarations for the Diavlo family - one for regular text, and one for a heavier weighted version of the typeface - then I later utilize Diavlo in a ",
		md_code("font-family:"),
		" attribute, it should refer to the basic Diavlo font defined in the first ",
		md_code("@font-face"),
		". However, if I were to do the same, but also specify a heavy ",
		md_code("font-weight:"),
		", then it should use the heavier version of Diavlo. To place this example in code:"
	]),
	md_el(:code,[],{:raw_code=>"@font-face {\n  font-family: 'Diavlo';\n  src: url(./Diavlo/Diavlo_Book.otf) format(\"opentype\");\n}\n\n@font-face {\n  font-family: 'Diavlo';\n  font-weight: 900;\n  src: url(./Diavlo/Diavlo_Black.otf) format(\"opentype\");\n}\n\nh1, h2, h3, h4, h5, h6 {\n  font-family: 'Diavlo';\n  font-weight: 900;\n}\n\ndiv#content {\n  font-family: 'Diavlo';\n}"},[]),
	md_par([
		"As you can see, my headings should use the typeface defined in ",
		md_code("Diavlo_Black.otf"),
		", while my body content should use ",
		md_code("Diavlo_Book.otf"),
		". However, in WebKit, this doesn",
		md_entity("rsquo"),
		"t work - it completely ignores any attribute except ",
		md_code("font-family:"),
		" and ",
		md_code("src:"),
		" in a ",
		md_code("@font-face"),
		" declaration! Completely ignores them! Not only that - not ",
		md_em(["only"]),
		" that - it disregards all but the last ",
		md_code("@font-face"),
		" for a given ",
		md_code("font-family:"),
		" attribute string!"
	]),
	md_par([
		"The implication here is that, to make ",
		md_code("@font-face"),
		" work as it is currently implemented in WebKit (and thus, Safari 3.1), I have to declare ",
		md_em(["completely imaginary, non-existent type families"]),
		" to satisfy WebKit alone. Here",
		md_entity("rsquo"),
		"s the method I have used in the places I current implement ",
		md_code("@font-face"),
		":"
	]),
	md_el(:code,[],{:raw_code=>"@font-face {\n  font-family: 'Diavlo Book';\n  src: url(./Diavlo/Diavlo_Book.otf) format(\"opentype\");\n}\n\n@font-face {\n  font-family: 'Diavlo Black';\n  src: url(./Diavlo/Diavlo_Black.otf) format(\"opentype\");\n}\n\nh1, h2, h3, h4, h5, h6 {\n  font-family: 'Diavlo Black';\n}\n\ndiv#content {\n  font-family: 'Diavlo Book';\n}"},[]),
	md_par([
		"Isn",
		md_entity("rsquo"),
		"t it horrible? Seriously, my eyes, they bleed. There",
		md_entity("rsquo"),
		"s lots of problems with this far beyond the lack of semanticity when it comes to the typeface names",
		md_entity("hellip"),
		" let me see how many ways this breaks the purpose of ",
		md_code("@font-face"),
		":"
	]),
	md_el(:ul,[
		md_el(:li,[
			md_par([
				"You remove a large element our control over the display of the page."
			]),
			md_par([
				"As soon as we begin to use ",
				md_code("@font-face"),
				" in our page, we can no longer make any use of any other textual control attribute - ",
				md_code("font-weight:"),
				", ",
				md_code("font-style:"),
				", and ",
				md_code("font-variant:"),
				" are no longer available to us, because they no longer correctly map to technical typeface variant/features."
			]),
			md_par([
				"Also, many default elements are destroyed, unusable, without ",
				md_entity("lsquo"),
				"fixing",
				md_entity("rsquo"),
				" - for instance, ",
				md_code("<b>"),
				" would have no effect in a page styled for WebKit as above; We would have to specify something like ",
				md_code("b {font-family: 'Diavlo Black';}"),
				" - how broken is that? Unless we caught all such default elements and re-styled them to use the bastardized names instead of the correct attributes, lots of basic HTML formatting would be broken. I myself may never use in-document formatting (separation of design and content!), but what about comments forms? Forum posts? Direct HTML-literal quotes?"
			]),
			md_par([
				"If we want to use Javascript to modify the display of the content, we can",
				md_entity("rsquo"),
				"t simply adjust the mentioned textual control attributes - we have to know and change the entire ",
				md_code("font-family:"),
				" array of strings."
			])
		],{:want_my_paragraph=>true},[]),
		md_el(:li,[
			md_par(["You make us very wet."]),
			md_par([
				"And by wet, I mean ",
				md_entity("lsquo"),
				"not DRY",
				md_entity("rsquo"),
				". What if we decide to change one of the bastardized font names? Or use a different font entirely? We have to go through all of our CSS, all of our Javascript, and make sure we update every occurrence of the typeface",
				md_entity("rsquo"),
				"s bastardized name."
			])
		],{:want_my_paragraph=>true},[]),
		md_el(:li,[
			md_par([
				"You remove our user",
				md_entity("rsquo"),
				"s user choice, and waste bandwidth."
			]),
			md_par([
				"Since the names refer to families that don",
				md_entity("rsquo"),
				"t, in fact, exist, the browser can",
				md_entity("rsquo"),
				"t override the declaration with a user",
				md_entity("rsquo"),
				"s installed version of the typeface. This means that, regardless of whether the user already has the typeface installed on their own computer, the browser won",
				md_entity("rsquo"),
				"t use that - it doesn",
				md_entity("rsquo"),
				"t know to use ",
				md_entity("lsquo"),
				"Diavlo",
				md_entity("rsquo"),
				", which the user has installed, because it was told to use ",
				md_entity("lsquo"),
				"Diavlo Black",
				md_entity("rsquo"),
				", which no user in the entire world has installed on their computer."
			])
		],{:want_my_paragraph=>true},[])
	],{},[]),
	md_par([
		"This whole thing is rather worrying - I",
		md_entity("rsquo"),
		"ve heard Opera has ",
		md_code("@font-face"),
		" support, though I haven",
		md_entity("rsquo"),
		"t had time to test this myself, so I don",
		md_entity("rsquo"),
		"t know if it actually does - or, for that matter, if it does it ",
		md_entity("lsquo"),
		"correctly",
		md_entity("rsquo"),
		", or has the same problems as WebKit. But either way, WebKit is one of the first two implementations to ever attempt to support ",
		md_code("@font-face"),
		" (Microsoft",
		md_entity("rsquo"),
		"s unrelated ",
		md_code("@font-face"),
		" declaration notwithstanding) - I really don",
		md_entity("rsquo"),
		"t want to see it",
		md_entity("rsquo"),
		"s early mistakes carried on to FireFox in a few years, and then Internet Explorer a few decades after that. That will leave us stuck with this broken system forever, as it has been demonstrated time and time again that if nobody else supports an old standard correctly, a newcomer to the standard will not do it correctly either. I for one would really, really, hate that."
	]),
	md_par([
		"In summary",
		md_entity("hellip"),
		" come on, WebKit team, this isn",
		md_entity("rsquo"),
		"t like you - you",
		md_entity("rsquo"),
		"re always the ones with the closest-to-standard implementation, and the cleanest code, and",
		md_entity("hellip"),
		" hell, overall? Webkit is the most secure/fastest browser available. But this is making me lose my faith in you, guys, please get it right. You",
		md_entity("rsquo"),
		"re pioneering a leap into the future when it comes to the Web - this is as important, or ",
		md_em(["more"]),
		" important, than Mosiac",
		md_entity("rsquo"),
		"s allowing of images was."
	]),
	md_par([
		"To put it succinctly - don",
		md_entity("rsquo"),
		"t fuck this up, y",
		md_entity("rsquo"),
		"all."
	]),
	md_ref_def("museo", "http://www.josbuivenga.demon.nl/museo.html>", {:title=>"Jos Buivenga"}),
	md_ref_def("diavlo", "http://www.josbuivenga.demon.nl/diavlo.html>", {:title=>"Jos Buivenga"}),
	md_par([
		md_em([md_link(["CSS"],"css"), ": Cascading Style Sheets"]),
		md_link([".EOT"],"eot"),
		": Embedded OpenType ",
		md_foot_ref("^eot"),
		": To give Microsoft a little credit, something I rarely do",
		md_entity("hellip"),
		" Yes, I",
		md_entity("rsquo"),
		"m aware Microsoft submitted EOT to the W3C as a proposal - the problem isn",
		md_entity("rsquo"),
		"t with their attempts to make it non-proprietary, but with the basic concept of making typefaces on the web DRMed. Look what such attempts have done to the music and video industry - simply decimated it. Do we really want to see the same thing happen to our beloved medium as typography moves into the 21st century? ",
		md_em([md_link(["W3C"],"w3c"), ": World Wide Web Consortium"])
	]),
	md_ref_def("w3c", "http://w3c.org>", {:title=>"World Wide Web Consortium"}),
	md_ref_def("spec", "http://?>", {:title=>")   *[DRY]: Don"})
],{},[])
*** Output of to_html ***
<h1 id='webkit_safari_31_and_the_css_fontface_declaration'>WebKit (Safari 3.1) and the CSS @font-face declaration</h1>

<p>I&#8217;m a big fan of typography in general. If you check out <a href='http://elliottcable.name'>my homepage</a> or my <a href='http://elliottcable.name/contact.xhtml'>contact elliottcable</a> page, and you&#8217;re using Safari/WebKit or Opera/Kestrel, you&#8217;ll notice the typefaces (fonts, as colloquialized) are <em>very</em> non-standard. (As of this writing, I&#8217;m using <a href='http://www.josbuivenga.demon.nl/museo.html&gt;' title='Jos Buivenga'>Museo</a> and <a href='http://www.josbuivenga.demon.nl/diavlo.html&gt;' title='Jos Buivenga'>Diavlo</a><sup id='fnref:1'><a href='#fn:1' rel='footnote'>1</a></sup> heavily on both.)</p>

<p>The internet has not be a friendly place for typohiles like myself, up to this point, at least. One might even say it was a frightful, mentally scarring environment for those akin to yours truly. We&#8217;ve been restricted to reading page after page after page on day after day after day for year after year after year abominations of markup and design enslaved by the horrible overlords we know as Lucida, Verdana, Arial, Helvetica, Geneva, Georgia, Courier, and&#8230; dare I invoke ye, thou my terrible overlord? Times New Roman.</p>

<p>Wherefore art thou, my glorious Archer? And thee as well, my beautiful Garamond? The technical restrictions of that horrible monster we know as the Web Browser hath forced us all too long to use those most banal, those most common, and those most abused, out of all of the typefaces of the world.</p>

<p>All hyperbole aside, I&#8217;m extremely happy to see the advent of a standard <code>@font-face</code> declaration in CSS. Internet Explorer first implemented a crutched, basic version of this way back in version 4, but nothing ever really came of it - their decision to create the proprietary .EOT<sup id='fnref:2'><a href='#fn:2' rel='footnote'>2</a></sup> format to appease overly restrictive type foundries&#8217; worries about intellectual property (aka. the cold, hard dominatrix that we know only as Ms. Profit) truly and completely killed that initial attempt at bringing astute typography and it&#8217;s advocates to the web. This new run at <code>@font-face</code> by an established, trusted, and open group (the <a href='http://w3c.org&gt;' title='World Wide Web Consortium'>W3C</a> itself, responsible for helping to make much of what we use as designers on the web standard and cross-system compatible) has a much better chance, in my humble opinion - and I am quite looking forward to the consequences if it succeeds.</p>

<p>Now, onwards to the topic of my post as declared in the header (yes, I know, a slow start - but it&#8217;s an interesting topic with an interesting history!). WebKit, the open source rendering engine behind the wonderfulness that is Safari, and how it handles the &#8216;new&#8217; <code>@font-face</code> declaration. No, it&#8217;s not really &#8216;new&#8217;, but yes, it feels like it is.</p>

<p>To put it simply, and to be very blunt, it&#8217;s broken.</p>

<p>The <a href='http://?&gt;' title=')   *[DRY]: Don'>CSS spec section</a> for <code>@font-face</code> is very specific - typefaces are to be selected based on a wide array of criteria placed in the <code>@font-face</code> declaration block itself. Various textual CSS attributes may be defined within the <code>@font-face</code> declaration, and then they will be checked when the typeface is referred to later in the CSS. For instance, if I have two <code>@font-face</code> declarations for the Diavlo family - one for regular text, and one for a heavier weighted version of the typeface - then I later utilize Diavlo in a <code>font-family:</code> attribute, it should refer to the basic Diavlo font defined in the first <code>@font-face</code>. However, if I were to do the same, but also specify a heavy <code>font-weight:</code>, then it should use the heavier version of Diavlo. To place this example in code:</p>

<pre><code>@font-face {
  font-family: &#39;Diavlo&#39;;
  src: url(./Diavlo/Diavlo_Book.otf) format(&quot;opentype&quot;);
}

@font-face {
  font-family: &#39;Diavlo&#39;;
  font-weight: 900;
  src: url(./Diavlo/Diavlo_Black.otf) format(&quot;opentype&quot;);
}

h1, h2, h3, h4, h5, h6 {
  font-family: &#39;Diavlo&#39;;
  font-weight: 900;
}

div#content {
  font-family: &#39;Diavlo&#39;;
}</code></pre>

<p>As you can see, my headings should use the typeface defined in <code>Diavlo_Black.otf</code>, while my body content should use <code>Diavlo_Book.otf</code>. However, in WebKit, this doesn&#8217;t work - it completely ignores any attribute except <code>font-family:</code> and <code>src:</code> in a <code>@font-face</code> declaration! Completely ignores them! Not only that - not <em>only</em> that - it disregards all but the last <code>@font-face</code> for a given <code>font-family:</code> attribute string!</p>

<p>The implication here is that, to make <code>@font-face</code> work as it is currently implemented in WebKit (and thus, Safari 3.1), I have to declare <em>completely imaginary, non-existent type families</em> to satisfy WebKit alone. Here&#8217;s the method I have used in the places I current implement <code>@font-face</code>:</p>

<pre><code>@font-face {
  font-family: &#39;Diavlo Book&#39;;
  src: url(./Diavlo/Diavlo_Book.otf) format(&quot;opentype&quot;);
}

@font-face {
  font-family: &#39;Diavlo Black&#39;;
  src: url(./Diavlo/Diavlo_Black.otf) format(&quot;opentype&quot;);
}

h1, h2, h3, h4, h5, h6 {
  font-family: &#39;Diavlo Black&#39;;
}

div#content {
  font-family: &#39;Diavlo Book&#39;;
}</code></pre>

<p>Isn&#8217;t it horrible? Seriously, my eyes, they bleed. There&#8217;s lots of problems with this far beyond the lack of semanticity when it comes to the typeface names&#8230; let me see how many ways this breaks the purpose of <code>@font-face</code>:</p>

<ul>
<li>
<p>You remove a large element our control over the display of the page.</p>

<p>As soon as we begin to use <code>@font-face</code> in our page, we can no longer make any use of any other textual control attribute - <code>font-weight:</code>, <code>font-style:</code>, and <code>font-variant:</code> are no longer available to us, because they no longer correctly map to technical typeface variant/features.</p>

<p>Also, many default elements are destroyed, unusable, without &#8216;fixing&#8217; - for instance, <code>&lt;b&gt;</code> would have no effect in a page styled for WebKit as above; We would have to specify something like <code>b {font-family: &#39;Diavlo Black&#39;;}</code> - how broken is that? Unless we caught all such default elements and re-styled them to use the bastardized names instead of the correct attributes, lots of basic HTML formatting would be broken. I myself may never use in-document formatting (separation of design and content!), but what about comments forms? Forum posts? Direct HTML-literal quotes?</p>

<p>If we want to use Javascript to modify the display of the content, we can&#8217;t simply adjust the mentioned textual control attributes - we have to know and change the entire <code>font-family:</code> array of strings.</p>
</li>

<li>
<p>You make us very wet.</p>

<p>And by wet, I mean &#8216;not DRY&#8217;. What if we decide to change one of the bastardized font names? Or use a different font entirely? We have to go through all of our CSS, all of our Javascript, and make sure we update every occurrence of the typeface&#8217;s bastardized name.</p>
</li>

<li>
<p>You remove our user&#8217;s user choice, and waste bandwidth.</p>

<p>Since the names refer to families that don&#8217;t, in fact, exist, the browser can&#8217;t override the declaration with a user&#8217;s installed version of the typeface. This means that, regardless of whether the user already has the typeface installed on their own computer, the browser won&#8217;t use that - it doesn&#8217;t know to use &#8216;Diavlo&#8217;, which the user has installed, because it was told to use &#8216;Diavlo Black&#8217;, which no user in the entire world has installed on their computer.</p>
</li>
</ul>

<p>This whole thing is rather worrying - I&#8217;ve heard Opera has <code>@font-face</code> support, though I haven&#8217;t had time to test this myself, so I don&#8217;t know if it actually does - or, for that matter, if it does it &#8216;correctly&#8217;, or has the same problems as WebKit. But either way, WebKit is one of the first two implementations to ever attempt to support <code>@font-face</code> (Microsoft&#8217;s unrelated <code>@font-face</code> declaration notwithstanding) - I really don&#8217;t want to see it&#8217;s early mistakes carried on to FireFox in a few years, and then Internet Explorer a few decades after that. That will leave us stuck with this broken system forever, as it has been demonstrated time and time again that if nobody else supports an old standard correctly, a newcomer to the standard will not do it correctly either. I for one would really, really, hate that.</p>

<p>In summary&#8230; come on, WebKit team, this isn&#8217;t like you - you&#8217;re always the ones with the closest-to-standard implementation, and the cleanest code, and&#8230; hell, overall? Webkit is the most secure/fastest browser available. But this is making me lose my faith in you, guys, please get it right. You&#8217;re pioneering a leap into the future when it comes to the Web - this is as important, or <em>more</em> important, than Mosiac&#8217;s allowing of images was.</p>

<p>To put it succinctly - don&#8217;t fuck this up, y&#8217;all.</p>

<p><em><span>CSS</span>: Cascading Style Sheets</em><span>.EOT</span>: Embedded OpenType <sup id='fnref:3'><a href='#fn:3' rel='footnote'>3</a></sup>: To give Microsoft a little credit, something I rarely do&#8230; Yes, I&#8217;m aware Microsoft submitted EOT to the W3C as a proposal - the problem isn&#8217;t with their attempts to make it non-proprietary, but with the basic concept of making typefaces on the web DRMed. Look what such attempts have done to the music and video industry - simply decimated it. Do we really want to see the same thing happen to our beloved medium as typography moves into the 21st century? <em><a href='http://w3c.org&gt;' title='World Wide Web Consortium'>W3C</a>: World Wide Web Consortium</em></p>
<div class='footnotes'><hr /><ol /></div>
*** Output of to_latex ***
#<NameError: undefined local variable or method `fid' for md_foot_ref("^jos"):MaRuKu::MDElement>
./lib/maruku/output/to_latex.rb:466:in `to_latex_footnote_reference'
./lib/maruku/output/to_latex.rb:538:in `send'
./lib/maruku/output/to_latex.rb:538:in `array_to_latex'
./lib/maruku/output/to_latex.rb:529:in `each'
./lib/maruku/output/to_latex.rb:529:in `array_to_latex'
./lib/maruku/output/to_latex.rb:524:in `children_to_latex'
./lib/maruku/output/to_latex.rb:158:in `to_latex_paragraph'
./lib/maruku/output/to_latex.rb:538:in `send'
./lib/maruku/output/to_latex.rb:538:in `array_to_latex'
./lib/maruku/output/to_latex.rb:529:in `each'
./lib/maruku/output/to_latex.rb:529:in `array_to_latex'
./lib/maruku/output/to_latex.rb:524:in `children_to_latex'
./lib/maruku/output/to_latex.rb:42:in `to_latex'
bin/marutest:93:in `send'
bin/marutest:93:in `run_test'
bin/marutest:88:in `each'
bin/marutest:88:in `run_test'
bin/marutest:262:in `marutest'
bin/marutest:259:in `each'
bin/marutest:259:in `marutest'
bin/marutest:334
*** Output of to_md ***
WebKit (Safari 3.1) and the CSS @font-face declarationI m a big fan of typography in general.
If you check out my homepageor my
contact elliottcablepage, and you re
using Safari/WebKit or Opera/Kestrel,
you ll notice the typefaces (fonts, as
colloquialized) are verynon-standard.
(As of this writing, I m using Museoand
Diavloheavily on both.)

The internet has not be a friendly
place for typohiles like myself, up to
this point, at least. One might even
say it was a frightful, mentally
scarring environment for those akin to
yours truly. We ve been restricted to
reading page after page after page on
day after day after day for year after
year after year abominations of markup
and design enslaved by the horrible
overlords we know as Lucida, Verdana,
Arial, Helvetica, Geneva, Georgia,
Courier, and dare I invoke ye, thou my
terrible overlord? Times New Roman.

Wherefore art thou, my glorious Archer?
And thee as well, my beautiful
Garamond? The technical restrictions of
that horrible monster we know as the
Web Browser hath forced us all too long
to use those most banal, those most
common, and those most abused, out of
all of the typefaces of the world.

All hyperbole aside, I m extremely
happy to see the advent of a standard
declaration in CSS. Internet Explorer
first implemented a crutched, basic
version of this way back in version 4,
but nothing ever really came of it -
their decision to create the
proprietary .EOT format to appease
overly restrictive type foundries
worries about intellectual property
(aka. the cold, hard dominatrix that we
know only as Ms. Profit) truly and
completely killed that initial attempt
at bringing astute typography and it s
advocates to the web. This new run at
by an established, trusted, and open
group (the W3Citself, responsible for
helping to make much of what we use as
designers on the web standard and
cross-system compatible) has a much
better chance, in my humble opinion -
and I am quite looking forward to the
consequences if it succeeds.

Now, onwards to the topic of my post as
declared in the header (yes, I know, a
slow start - but it s an interesting
topic with an interesting history!).
WebKit, the open source rendering
engine behind the wonderfulness that is
Safari, and how it handles the new
declaration. No, it s not really new ,
but yes, it feels like it is.

To put it simply, and to be very blunt,
it s broken.

The CSS spec sectionfor is very
specific - typefaces are to be selected
based on a wide array of criteria
placed in the declaration block itself.
Various textual CSS attributes may be
defined within the declaration, and
then they will be checked when the
typeface is referred to later in the
CSS. For instance, if I have two
declarations for the Diavlo family -
one for regular text, and one for a
heavier weighted version of the
typeface - then I later utilize Diavlo
in a attribute, it should refer to the
basic Diavlo font defined in the first
. However, if I were to do the same,
but also specify a heavy , then it
should use the heavier version of
Diavlo. To place this example in code:

As you can see, my headings should use
the typeface defined in , while my body
content should use . However, in
WebKit, this doesn t work - it
completely ignores any attribute except
and in a declaration! Completely
ignores them! Not only that - not only
that - it disregards all but the last
for a given attribute string!

The implication here is that, to make
work as it is currently implemented in
WebKit (and thus, Safari 3.1), I have
to declare
completely imaginary, non-existent type families
to satisfy WebKit alone. Here s the
method I have used in the places I
current implement :

Isn t it horrible? Seriously, my eyes,
they bleed. There s lots of problems
with this far beyond the lack of
semanticity when it comes to the
typeface names let me see how many ways
this breaks the purpose of :

-You remove a large element our control over the display of the page.
As soon as we begin to use  in our page, we can no longer make any use of any other textual control attribute - , , and  are no longer available to us, because they no longer correctly map to technical typeface variant/features.
Also, many default elements are destroyed, unusable, without fixing - for instance,  would have no effect in a page styled for WebKit as above; We would have to specify something like  - how broken is that? Unless we caught all such default elements and re-styled them to use the bastardized names instead of the correct attributes, lots of basic HTML formatting would be broken. I myself may never use in-document formatting (separation of design and content!), but what about comments forms? Forum posts? Direct HTML-literal quotes?
If we want to use Javascript to modify the display of the content, we cant simply adjust the mentioned textual control attributes - we have to know and change the entire  array of strings.
-ou make us very wet.
And by wet, I mean not DRY. What if we decide to change one of the bastardized font names? Or use a different font entirely? We have to go through all of our CSS, all of our Javascript, and make sure we update every occurrence of the typefaces bastardized name.
-You remove our users user choice, and waste bandwidth.
Since the names refer to families that dont, in fact, exist, the browser cant override the declaration with a users installed version of the typeface. This means that, regardless of whether the user already has the typeface installed on their own computer, the browser wont use that - it doesnt know to use Diavlo, which the user has installed, because it was told to use Diavlo Black, which no user in the entire world has installed on their computer.

This whole thing is rather worrying - I
ve heard Opera has support, though I
haven t had time to test this myself,
so I don t know if it actually does -
or, for that matter, if it does it
correctly , or has the same problems as
WebKit. But either way, WebKit is one
of the first two implementations to
ever attempt to support (Microsoft s
unrelated declaration notwithstanding)
- I really don t want to see it s early
mistakes carried on to FireFox in a few
years, and then Internet Explorer a few
decades after that. That will leave us
stuck with this broken system forever,
as it has been demonstrated time and
time again that if nobody else supports
an old standard correctly, a newcomer
to the standard will not do it
correctly either. I for one would
really, really, hate that.

In summary come on, WebKit team, this
isn t like you - you re always the ones
with the closest-to-standard
implementation, and the cleanest code,
and hell, overall? Webkit is the most
secure/fastest browser available. But
this is making me lose my faith in you,
guys, please get it right. You re
pioneering a leap into the future when
it comes to the Web - this is as
important, or moreimportant, than
Mosiac s allowing of images was.

To put it succinctly - don t fuck this
up, y all.

CSS: Cascading Style Sheets.EOT:
Embedded OpenType : To give Microsoft a
little credit, something I rarely do
Yes, I m aware Microsoft submitted EOT
to the W3C as a proposal - the problem
isn t with their attempts to make it
non-proprietary, but with the basic
concept of making typefaces on the web
DRMed. Look what such attempts have
done to the music and video industry -
simply decimated it. Do we really want
to see the same thing happen to our
beloved medium as typography moves into
the 21st century?
W3C: World Wide Web Consortium
*** Output of to_s ***
WebKit (Safari 3.1) and the CSS @font-face declarationIm a big fan of typography in general. If you check out my homepage or my contact elliottcable page, and youre using Safari/WebKit or Opera/Kestrel, youll notice the typefaces (fonts, as colloquialized) are very non-standard. (As of this writing, Im using Museo and Diavlo heavily on both.)The internet has not be a friendly place for typohiles like myself, up to this point, at least. One might even say it was a frightful, mentally scarring environment for those akin to yours truly. Weve been restricted to reading page after page after page on day after day after day for year after year after year abominations of markup and design enslaved by the horrible overlords we know as Lucida, Verdana, Arial, Helvetica, Geneva, Georgia, Courier, and dare I invoke ye, thou my terrible overlord? Times New Roman.Wherefore art thou, my glorious Archer? And thee as well, my beautiful Garamond? The technical restrictions of that horrible monster we know as the Web Browser hath forced us all too long to use those most banal, those most common, and those most abused, out of all of the typefaces of the world.All hyperbole aside, Im extremely happy to see the advent of a standard  declaration in CSS. Internet Explorer first implemented a crutched, basic version of this way back in version 4, but nothing ever really came of it - their decision to create the proprietary .EOT format to appease overly restrictive type foundries worries about intellectual property (aka. the cold, hard dominatrix that we know only as Ms. Profit) truly and completely killed that initial attempt at bringing astute typography and its advocates to the web. This new run at  by an established, trusted, and open group (the W3C itself, responsible for helping to make much of what we use as designers on the web standard and cross-system compatible) has a much better chance, in my humble opinion - and I am quite looking forward to the consequences if it succeeds.Now, onwards to the topic of my post as declared in the header (yes, I know, a slow start - but its an interesting topic with an interesting history!). WebKit, the open source rendering engine behind the wonderfulness that is Safari, and how it handles the new  declaration. No, its not really new, but yes, it feels like it is.To put it simply, and to be very blunt, its broken.The CSS spec section for  is very specific - typefaces are to be selected based on a wide array of criteria placed in the  declaration block itself. Various textual CSS attributes may be defined within the  declaration, and then they will be checked when the typeface is referred to later in the CSS. For instance, if I have two  declarations for the Diavlo family - one for regular text, and one for a heavier weighted version of the typeface - then I later utilize Diavlo in a  attribute, it should refer to the basic Diavlo font defined in the first . However, if I were to do the same, but also specify a heavy , then it should use the heavier version of Diavlo. To place this example in code:As you can see, my headings should use the typeface defined in , while my body content should use . However, in WebKit, this doesnt work - it completely ignores any attribute except  and  in a  declaration! Completely ignores them! Not only that - not only that - it disregards all but the last  for a given  attribute string!The implication here is that, to make  work as it is currently implemented in WebKit (and thus, Safari 3.1), I have to declare completely imaginary, non-existent type families to satisfy WebKit alone. Heres the method I have used in the places I current implement :Isnt it horrible? Seriously, my eyes, they bleed. Theres lots of problems with this far beyond the lack of semanticity when it comes to the typeface names let me see how many ways this breaks the purpose of :You remove a large element our control over the display of the page.As soon as we begin to use  in our page, we can no longer make any use of any other textual control attribute - , , and  are no longer available to us, because they no longer correctly map to technical typeface variant/features.Also, many default elements are destroyed, unusable, without fixing - for instance,  would have no effect in a page styled for WebKit as above; We would have to specify something like  - how broken is that? Unless we caught all such default elements and re-styled them to use the bastardized names instead of the correct attributes, lots of basic HTML formatting would be broken. I myself may never use in-document formatting (separation of design and content!), but what about comments forms? Forum posts? Direct HTML-literal quotes?If we want to use Javascript to modify the display of the content, we cant simply adjust the mentioned textual control attributes - we have to know and change the entire  array of strings.You make us very wet.And by wet, I mean not DRY. What if we decide to change one of the bastardized font names? Or use a different font entirely? We have to go through all of our CSS, all of our Javascript, and make sure we update every occurrence of the typefaces bastardized name.You remove our users user choice, and waste bandwidth.Since the names refer to families that dont, in fact, exist, the browser cant override the declaration with a users installed version of the typeface. This means that, regardless of whether the user already has the typeface installed on their own computer, the browser wont use that - it doesnt know to use Diavlo, which the user has installed, because it was told to use Diavlo Black, which no user in the entire world has installed on their computer.This whole thing is rather worrying - Ive heard Opera has  support, though I havent had time to test this myself, so I dont know if it actually does - or, for that matter, if it does it correctly, or has the same problems as WebKit. But either way, WebKit is one of the first two implementations to ever attempt to support  (Microsofts unrelated  declaration notwithstanding) - I really dont want to see its early mistakes carried on to FireFox in a few years, and then Internet Explorer a few decades after that. That will leave us stuck with this broken system forever, as it has been demonstrated time and time again that if nobody else supports an old standard correctly, a newcomer to the standard will not do it correctly either. I for one would really, really, hate that.In summary come on, WebKit team, this isnt like you - youre always the ones with the closest-to-standard implementation, and the cleanest code, and hell, overall? Webkit is the most secure/fastest browser available. But this is making me lose my faith in you, guys, please get it right. Youre pioneering a leap into the future when it comes to the Web - this is as important, or more important, than Mosiacs allowing of images was.To put it succinctly - dont fuck this up, yall.CSS: Cascading Style Sheets.EOT: Embedded OpenType : To give Microsoft a little credit, something I rarely do Yes, Im aware Microsoft submitted EOT to the W3C as a proposal - the problem isnt with their attempts to make it non-proprietary, but with the basic concept of making typefaces on the web DRMed. Look what such attempts have done to the music and video industry - simply decimated it. Do we really want to see the same thing happen to our beloved medium as typography moves into the 21st century? W3C: World Wide Web Consortium
*** EOF ***




Failed tests:   [:inspect, :to_html, :to_latex, :to_md, :to_s] 

*** Output of inspect ***
-----| WARNING | -----
md_el(:document,[
	md_el(:header,[
		"WebKit (Safari 3.1) and the ",
		md_el(:abbr,["CSS"],{:title=>"Cascading Style Sheets"},[]),
		" @font-face declaration"
	],{:level=>1},[]),
	md_par([
		"I",
		md_entity("rsquo"),
		"m a big fan of typography in general. If you check out ",
		md_im_link(["my homepage"], "http://elliottcable.name", nil),
		" or my ",
		md_im_link(["contact elliottcable"], "http://elliottcable.name/contact.xhtml", nil),
		" page, and you",
		md_entity("rsquo"),
		"re using Safari/WebKit or Opera/Kestrel, you",
		md_entity("rsquo"),
		"ll notice the typefaces (fonts, as colloquialized) are ",
		md_em(["very"]),
		" non-standard. (As of this writing, I",
		md_entity("rsquo"),
		"m using ",
		md_link(["Museo"],"museo"),
		" and ",
		md_link(["Diavlo"],"diavlo"),
		md_foot_ref("^jos"),
		" heavily on both.)"
	]),
	md_par([
		"The internet has not be a friendly place for typohiles like myself, up to this point, at least. One might even say it was a frightful, mentally scarring environment for those akin to yours truly. We",
		md_entity("rsquo"),
		"ve been restricted to reading page after page after page on day after day after day for year after year after year abominations of markup and design enslaved by the horrible overlords we know as Lucida, Verdana, Arial, Helvetica, Geneva, Georgia, Courier, and",
		md_entity("hellip"),
		" dare I invoke ye, thou my terrible overlord? Times New Roman."
	]),
	md_par([
		"Wherefore art thou, my glorious Archer? And thee as well, my beautiful Garamond? The technical restrictions of that horrible monster we know as the Web Browser hath forced us all too long to use those most banal, those most common, and those most abused, out of all of the typefaces of the world."
	]),
	md_par([
		"All hyperbole aside, I",
		md_entity("rsquo"),
		"m extremely happy to see the advent of a standard ",
		md_code("@font-face"),
		" declaration in ",
		md_el(:abbr,["CSS"],{:title=>"Cascading Style Sheets"},[]),
		". Internet Explorer first implemented a crutched, basic version of this way back in version 4, but nothing ever really came of it - their decision to create the proprietary ",
		md_el(:abbr,[".EOT"],{:title=>"Embedded OpenType"},[]),
		md_foot_ref("^eot"),
		" format to appease overly restrictive type foundries",
		md_entity("rsquo"),
		" worries about intellectual property (aka. the cold, hard dominatrix that we know only as Ms. Profit) truly and completely killed that initial attempt at bringing astute typography and it",
		md_entity("rsquo"),
		"s advocates to the web. This new run at ",
		md_code("@font-face"),
		" by an established, trusted, and open group (the ",
		md_link([
			"",
			md_el(:abbr,["W3C"],{:title=>"World Wide Web Consortium"},[]),
			""
		],"w3c"),
		" itself, responsible for helping to make much of what we use as designers on the web standard and cross-system compatible) has a much better chance, in my humble opinion - and I am quite looking forward to the consequences if it succeeds."
	]),
	md_par([
		"Now, onwards to the topic of my post as declared in the header (yes, I know, a slow start - but it",
		md_entity("rsquo"),
		"s an interesting topic with an interesting history!). WebKit, the open source rendering engine behind the wonderfulness that is Safari, and how it handles the ",
		md_entity("lsquo"),
		"new",
		md_entity("rsquo"),
		" ",
		md_code("@font-face"),
		" declaration. No, it",
		md_entity("rsquo"),
		"s not really ",
		md_entity("lsquo"),
		"new",
		md_entity("rsquo"),
		", but yes, it feels like it is."
	]),
	md_par([
		"To put it simply, and to be very blunt, it",
		md_entity("rsquo"),
		"s broken."
	]),
	md_par([
		"The ",
		md_link([
			md_el(:abbr,["CSS"],{:title=>"Cascading Style Sheets"},[]),
			" spec section"
		],"spec"),
		" for ",
		md_code("@font-face"),
		" is very specific - typefaces are to be selected based on a wide array of criteria placed in the ",
		md_code("@font-face"),
		" declaration block itself. Various textual ",
		md_el(:abbr,["CSS"],{:title=>"Cascading Style Sheets"},[]),
		" attributes may be defined within the ",
		md_code("@font-face"),
		" declaration, and then they will be checked when the typeface is referred to later in the ",
		md_el(:abbr,["CSS"],{:title=>"Cascading Style Sheets"},[]),
		". For instance, if I have two ",
		md_code("@font-face"),
		" declarations for the Diavlo family - one for regular text, and one for a heavier weighted version of the typeface - then I later utilize Diavlo in a ",
		md_code("font-family:"),
		" attribute, it should refer to the basic Diavlo font defined in the first ",
		md_code("@font-face"),
		". However, if I were to do the same, but also specify a heavy ",
		md_code("font-weight:"),
		", then it should use the heavier version of Diavlo. To place this example in code:"
	]),
	md_el(:code,[],{:raw_code=>"@font-face {\n  font-family: 'Diavlo';\n  src: url(./Diavlo/Diavlo_Book.otf) format(\"opentype\");\n}\n\n@font-face {\n  font-family: 'Diavlo';\n  font-weight: 900;\n  src: url(./Diavlo/Diavlo_Black.otf) format(\"opentype\");\n}\n\nh1, h2, h3, h4, h5, h6 {\n  font-family: 'Diavlo';\n  font-weight: 900;\n}\n\ndiv#content {\n  font-family: 'Diavlo';\n}"},[]),
	md_par([
		"As you can see, my headings should use the typeface defined in ",
		md_code("Diavlo_Black.otf"),
		", while my body content should use ",
		md_code("Diavlo_Book.otf"),
		". However, in WebKit, this doesn",
		md_entity("rsquo"),
		"t work - it completely ignores any attribute except ",
		md_code("font-family:"),
		" and ",
		md_code("src:"),
		" in a ",
		md_code("@font-face"),
		" declaration! Completely ignores them! Not only that - not ",
		md_em(["only"]),
		" that - it disregards all but the last ",
		md_code("@font-face"),
		" for a given ",
		md_code("font-family:"),
		" attribute string!"
	]),
	md_par([
		"The implication here is that, to make ",
		md_code("@font-face"),
		" work as it is currently implemented in WebKit (and thus, Safari 3.1), I have to declare ",
		md_em(["completely imaginary, non-existent type families"]),
		" to satisfy WebKit alone. Here",
		md_entity("rsquo"),
		"s the method I have used in the places I current implement ",
		md_code("@font-face"),
		":"
	]),
	md_el(:code,[],{:raw_code=>"@font-face {\n  font-family: 'Diavlo Book';\n  src: url(./Diavlo/Diavlo_Book.otf) format(\"opentype\");\n}\n\n@font-face {\n  font-family: 'Diavlo Black';\n  src: url(./Diavlo/Diavlo_Black.otf) format(\"opentype\");\n}\n\nh1, h2, h3, h4, h5, h6 {\n  font-family: 'Diavlo Black';\n}\n\ndiv#content {\n  font-family: 'Diavlo Book';\n}"},[]),
	md_par([
		"Isn",
		md_entity("rsquo"),
		"t it horrible? Seriously, my eyes, they bleed. There",
		md_entity("rsquo"),
		"s lots of problems with this far beyond the lack of semanticity when it comes to the typeface names",
		md_entity("hellip"),
		" let me see how many ways this breaks the purpose of ",
		md_code("@font-face"),
		":"
	]),
	md_el(:ul,[
		md_el(:li,[
			md_par([
				"You remove a large element our control over the display of the page."
			]),
			md_par([
				"As soon as we begin to use ",
				md_code("@font-face"),
				" in our page, we can no longer make any use of any other textual control attribute - ",
				md_code("font-weight:"),
				", ",
				md_code("font-style:"),
				", and ",
				md_code("font-variant:"),
				" are no longer available to us, because they no longer correctly map to technical typeface variant/features."
			]),
			md_par([
				"Also, many default elements are destroyed, unusable, without ",
				md_entity("lsquo"),
				"fixing",
				md_entity("rsquo"),
				" - for instance, ",
				md_code("<b>"),
				" would have no effect in a page styled for WebKit as above; We would have to specify something like ",
				md_code("b {font-family: 'Diavlo Black';}"),
				" - how broken is that? Unless we caught all such default elements and re-styled them to use the bastardized names instead of the correct attributes, lots of basic HTML formatting would be broken. I myself may never use in-document formatting (separation of design and content!), but what about comments forms? Forum posts? Direct HTML-literal quotes?"
			]),
			md_par([
				"If we want to use Javascript to modify the display of the content, we can",
				md_entity("rsquo"),
				"t simply adjust the mentioned textual control attributes - we have to know and change the entire ",
				md_code("font-family:"),
				" array of strings."
			])
		],{:want_my_paragraph=>true},[]),
		md_el(:li,[
			md_par(["You make us very wet."]),
			md_par([
				"And by wet, I mean ",
				md_entity("lsquo"),
				"not ",
				md_el(:abbr,["DRY"],{:title=>"Don't Repeat Yourself"},[]),
				md_entity("rsquo"),
				". What if we decide to change one of the bastardized font names? Or use a different font entirely? We have to go through all of our ",
				md_el(:abbr,["CSS"],{:title=>"Cascading Style Sheets"},[]),
				", all of our Javascript, and make sure we update every occurrence of the typeface",
				md_entity("rsquo"),
				"s bastardized name."
			])
		],{:want_my_paragraph=>true},[]),
		md_el(:li,[
			md_par([
				"You remove our user",
				md_entity("rsquo"),
				"s user choice, and waste bandwidth."
			]),
			md_par([
				"Since the names refer to families that don",
				md_entity("rsquo"),
				"t, in fact, exist, the browser can",
				md_entity("rsquo"),
				"t override the declaration with a user",
				md_entity("rsquo"),
				"s installed version of the typeface. This means that, regardless of whether the user already has the typeface installed on their own computer, the browser won",
				md_entity("rsquo"),
				"t use that - it doesn",
				md_entity("rsquo"),
				"t know to use ",
				md_entity("lsquo"),
				"Diavlo",
				md_entity("rsquo"),
				", which the user has installed, because it was told to use ",
				md_entity("lsquo"),
				"Diavlo Black",
				md_entity("rsquo"),
				", which no user in the entire world has installed on their computer."
			])
		],{:want_my_paragraph=>true},[])
	],{},[]),
	md_par([
		"This whole thing is rather worrying - I",
		md_entity("rsquo"),
		"ve heard Opera has ",
		md_code("@font-face"),
		" support, though I haven",
		md_entity("rsquo"),
		"t had time to test this myself, so I don",
		md_entity("rsquo"),
		"t know if it actually does - or, for that matter, if it does it ",
		md_entity("lsquo"),
		"correctly",
		md_entity("rsquo"),
		", or has the same problems as WebKit. But either way, WebKit is one of the first two implementations to ever attempt to support ",
		md_code("@font-face"),
		" (Microsoft",
		md_entity("rsquo"),
		"s unrelated ",
		md_code("@font-face"),
		" declaration notwithstanding) - I really don",
		md_entity("rsquo"),
		"t want to see it",
		md_entity("rsquo"),
		"s early mistakes carried on to FireFox in a few years, and then Internet Explorer a few decades after that. That will leave us stuck with this broken system forever, as it has been demonstrated time and time again that if nobody else supports an old standard correctly, a newcomer to the standard will not do it correctly either. I for one would really, really, hate that."
	]),
	md_par([
		"In summary",
		md_entity("hellip"),
		" come on, WebKit team, this isn",
		md_entity("rsquo"),
		"t like you - you",
		md_entity("rsquo"),
		"re always the ones with the closest-to-standard implementation, and the cleanest code, and",
		md_entity("hellip"),
		" hell, overall? Webkit is the most secure/fastest browser available. But this is making me lose my faith in you, guys, please get it right. You",
		md_entity("rsquo"),
		"re pioneering a leap into the future when it comes to the Web - this is as important, or ",
		md_em(["more"]),
		" important, than Mosiac",
		md_entity("rsquo"),
		"s allowing of images was."
	]),
	md_par([
		"To put it succinctly - don",
		md_entity("rsquo"),
		"t fuck this up, y",
		md_entity("rsquo"),
		"all."
	]),
	md_ref_def("museo", "http://www.josbuivenga.demon.nl/museo.html", {:title=>"Jos Buivenga"}),
	md_ref_def("diavlo", "http://www.josbuivenga.demon.nl/diavlo.html", {:title=>"Jos Buivenga"}),
	md_el(:footnote,[
		md_par([
			"These are fonts by ",
			md_link(["Jos Buivenga"],"jos"),
			", quite the amazing person. His (free) fonts are, uniquely, released for use on the web in ",
			md_code("@font-face"),
			" declarations - unlike the vast majority of other (even free to download) typefaces, which have ridiculously restricting licenses and terms of use statements. Props, Jos - you",
			md_entity("rsquo"),
			"re a pioneer, and deserve recognition as such."
		])
	],{:footnote_id=>"^jos"},[]),
	md_el(:abbr_def,[],{:abbr=>"CSS",:text=>"Cascading Style Sheets"},[]),
	md_el(:abbr_def,[],{:abbr=>".EOT",:text=>"Embedded OpenType"},[]),
	md_el(:footnote,[
		md_par([
			"To give Microsoft a little credit, something I rarely do",
			md_entity("hellip"),
			" Yes, I",
			md_entity("rsquo"),
			"m aware Microsoft submitted EOT to the ",
			md_el(:abbr,["W3C"],{:title=>"World Wide Web Consortium"},[]),
			" as a proposal - the problem isn",
			md_entity("rsquo"),
			"t with their attempts to make it non-proprietary, but with the basic concept of making typefaces on the web DRMed. Look what such attempts have done to the music and video industry - simply decimated it. Do we really want to see the same thing happen to our beloved medium as typography moves into the 21st century?"
		])
	],{:footnote_id=>"^eot"},[]),
	md_el(:abbr_def,[],{:abbr=>"W3C",:text=>"World Wide Web Consortium"},[]),
	md_ref_def("w3c", "http://w3c.org", {:title=>"World Wide Web Consortium"}),
	md_ref_def("spec", "http://?", {:title=>nil}),
	md_el(:abbr_def,[],{:abbr=>"DRY",:text=>"Don't Repeat Yourself"},[]),
	md_ref_def("jos", "jos", {:title=>nil})
],{},[])
*** Output of to_html ***
-----| WARNING | -----
<h1 id='webkit_safari_31_and_the_css_fontface_declaration'>WebKit (Safari 3.1) and the <abbr title='Cascading Style Sheets'>CSS</abbr> @font-face declaration</h1>

<p>I&#8217;m a big fan of typography in general. If you check out <a href='http://elliottcable.name'>my homepage</a> or my <a href='http://elliottcable.name/contact.xhtml'>contact elliottcable</a> page, and you&#8217;re using Safari/WebKit or Opera/Kestrel, you&#8217;ll notice the typefaces (fonts, as colloquialized) are <em>very</em> non-standard. (As of this writing, I&#8217;m using <a href='http://www.josbuivenga.demon.nl/museo.html' title='Jos Buivenga'>Museo</a> and <a href='http://www.josbuivenga.demon.nl/diavlo.html' title='Jos Buivenga'>Diavlo</a><sup id='fnref:1'><a href='#fn:1' rel='footnote'>1</a></sup> heavily on both.)</p>

<p>The internet has not be a friendly place for typohiles like myself, up to this point, at least. One might even say it was a frightful, mentally scarring environment for those akin to yours truly. We&#8217;ve been restricted to reading page after page after page on day after day after day for year after year after year abominations of markup and design enslaved by the horrible overlords we know as Lucida, Verdana, Arial, Helvetica, Geneva, Georgia, Courier, and&#8230; dare I invoke ye, thou my terrible overlord? Times New Roman.</p>

<p>Wherefore art thou, my glorious Archer? And thee as well, my beautiful Garamond? The technical restrictions of that horrible monster we know as the Web Browser hath forced us all too long to use those most banal, those most common, and those most abused, out of all of the typefaces of the world.</p>

<p>All hyperbole aside, I&#8217;m extremely happy to see the advent of a standard <code>@font-face</code> declaration in <abbr title='Cascading Style Sheets'>CSS</abbr>. Internet Explorer first implemented a crutched, basic version of this way back in version 4, but nothing ever really came of it - their decision to create the proprietary <abbr title='Embedded OpenType'>.EOT</abbr><sup id='fnref:2'><a href='#fn:2' rel='footnote'>2</a></sup> format to appease overly restrictive type foundries&#8217; worries about intellectual property (aka. the cold, hard dominatrix that we know only as Ms. Profit) truly and completely killed that initial attempt at bringing astute typography and it&#8217;s advocates to the web. This new run at <code>@font-face</code> by an established, trusted, and open group (the <a href='http://w3c.org' title='World Wide Web Consortium'><abbr title='World Wide Web Consortium'>W3C</abbr></a> itself, responsible for helping to make much of what we use as designers on the web standard and cross-system compatible) has a much better chance, in my humble opinion - and I am quite looking forward to the consequences if it succeeds.</p>

<p>Now, onwards to the topic of my post as declared in the header (yes, I know, a slow start - but it&#8217;s an interesting topic with an interesting history!). WebKit, the open source rendering engine behind the wonderfulness that is Safari, and how it handles the &#8216;new&#8217; <code>@font-face</code> declaration. No, it&#8217;s not really &#8216;new&#8217;, but yes, it feels like it is.</p>

<p>To put it simply, and to be very blunt, it&#8217;s broken.</p>

<p>The <a href='http://?'><abbr title='Cascading Style Sheets'>CSS</abbr> spec section</a> for <code>@font-face</code> is very specific - typefaces are to be selected based on a wide array of criteria placed in the <code>@font-face</code> declaration block itself. Various textual <abbr title='Cascading Style Sheets'>CSS</abbr> attributes may be defined within the <code>@font-face</code> declaration, and then they will be checked when the typeface is referred to later in the <abbr title='Cascading Style Sheets'>CSS</abbr>. For instance, if I have two <code>@font-face</code> declarations for the Diavlo family - one for regular text, and one for a heavier weighted version of the typeface - then I later utilize Diavlo in a <code>font-family:</code> attribute, it should refer to the basic Diavlo font defined in the first <code>@font-face</code>. However, if I were to do the same, but also specify a heavy <code>font-weight:</code>, then it should use the heavier version of Diavlo. To place this example in code:</p>

<pre><code>@font-face {
  font-family: &#39;Diavlo&#39;;
  src: url(./Diavlo/Diavlo_Book.otf) format(&quot;opentype&quot;);
}

@font-face {
  font-family: &#39;Diavlo&#39;;
  font-weight: 900;
  src: url(./Diavlo/Diavlo_Black.otf) format(&quot;opentype&quot;);
}

h1, h2, h3, h4, h5, h6 {
  font-family: &#39;Diavlo&#39;;
  font-weight: 900;
}

div#content {
  font-family: &#39;Diavlo&#39;;
}</code></pre>

<p>As you can see, my headings should use the typeface defined in <code>Diavlo_Black.otf</code>, while my body content should use <code>Diavlo_Book.otf</code>. However, in WebKit, this doesn&#8217;t work - it completely ignores any attribute except <code>font-family:</code> and <code>src:</code> in a <code>@font-face</code> declaration! Completely ignores them! Not only that - not <em>only</em> that - it disregards all but the last <code>@font-face</code> for a given <code>font-family:</code> attribute string!</p>

<p>The implication here is that, to make <code>@font-face</code> work as it is currently implemented in WebKit (and thus, Safari 3.1), I have to declare <em>completely imaginary, non-existent type families</em> to satisfy WebKit alone. Here&#8217;s the method I have used in the places I current implement <code>@font-face</code>:</p>

<pre><code>@font-face {
  font-family: &#39;Diavlo Book&#39;;
  src: url(./Diavlo/Diavlo_Book.otf) format(&quot;opentype&quot;);
}

@font-face {
  font-family: &#39;Diavlo Black&#39;;
  src: url(./Diavlo/Diavlo_Black.otf) format(&quot;opentype&quot;);
}

h1, h2, h3, h4, h5, h6 {
  font-family: &#39;Diavlo Black&#39;;
}

div#content {
  font-family: &#39;Diavlo Book&#39;;
}</code></pre>

<p>Isn&#8217;t it horrible? Seriously, my eyes, they bleed. There&#8217;s lots of problems with this far beyond the lack of semanticity when it comes to the typeface names&#8230; let me see how many ways this breaks the purpose of <code>@font-face</code>:</p>

<ul>
<li>
<p>You remove a large element our control over the display of the page.</p>

<p>As soon as we begin to use <code>@font-face</code> in our page, we can no longer make any use of any other textual control attribute - <code>font-weight:</code>, <code>font-style:</code>, and <code>font-variant:</code> are no longer available to us, because they no longer correctly map to technical typeface variant/features.</p>

<p>Also, many default elements are destroyed, unusable, without &#8216;fixing&#8217; - for instance, <code>&lt;b&gt;</code> would have no effect in a page styled for WebKit as above; We would have to specify something like <code>b {font-family: &#39;Diavlo Black&#39;;}</code> - how broken is that? Unless we caught all such default elements and re-styled them to use the bastardized names instead of the correct attributes, lots of basic HTML formatting would be broken. I myself may never use in-document formatting (separation of design and content!), but what about comments forms? Forum posts? Direct HTML-literal quotes?</p>

<p>If we want to use Javascript to modify the display of the content, we can&#8217;t simply adjust the mentioned textual control attributes - we have to know and change the entire <code>font-family:</code> array of strings.</p>
</li>

<li>
<p>You make us very wet.</p>

<p>And by wet, I mean &#8216;not <abbr title='Don&apos;t Repeat Yourself'>DRY</abbr>&#8217;. What if we decide to change one of the bastardized font names? Or use a different font entirely? We have to go through all of our <abbr title='Cascading Style Sheets'>CSS</abbr>, all of our Javascript, and make sure we update every occurrence of the typeface&#8217;s bastardized name.</p>
</li>

<li>
<p>You remove our user&#8217;s user choice, and waste bandwidth.</p>

<p>Since the names refer to families that don&#8217;t, in fact, exist, the browser can&#8217;t override the declaration with a user&#8217;s installed version of the typeface. This means that, regardless of whether the user already has the typeface installed on their own computer, the browser won&#8217;t use that - it doesn&#8217;t know to use &#8216;Diavlo&#8217;, which the user has installed, because it was told to use &#8216;Diavlo Black&#8217;, which no user in the entire world has installed on their computer.</p>
</li>
</ul>

<p>This whole thing is rather worrying - I&#8217;ve heard Opera has <code>@font-face</code> support, though I haven&#8217;t had time to test this myself, so I don&#8217;t know if it actually does - or, for that matter, if it does it &#8216;correctly&#8217;, or has the same problems as WebKit. But either way, WebKit is one of the first two implementations to ever attempt to support <code>@font-face</code> (Microsoft&#8217;s unrelated <code>@font-face</code> declaration notwithstanding) - I really don&#8217;t want to see it&#8217;s early mistakes carried on to FireFox in a few years, and then Internet Explorer a few decades after that. That will leave us stuck with this broken system forever, as it has been demonstrated time and time again that if nobody else supports an old standard correctly, a newcomer to the standard will not do it correctly either. I for one would really, really, hate that.</p>

<p>In summary&#8230; come on, WebKit team, this isn&#8217;t like you - you&#8217;re always the ones with the closest-to-standard implementation, and the cleanest code, and&#8230; hell, overall? Webkit is the most secure/fastest browser available. But this is making me lose my faith in you, guys, please get it right. You&#8217;re pioneering a leap into the future when it comes to the Web - this is as important, or <em>more</em> important, than Mosiac&#8217;s allowing of images was.</p>

<p>To put it succinctly - don&#8217;t fuck this up, y&#8217;all.</p>
<div class='footnotes'><hr /><ol><li id='fn:1'>
<p>These are fonts by <a href='jos'>Jos Buivenga</a>, quite the amazing person. His (free) fonts are, uniquely, released for use on the web in <code>@font-face</code> declarations - unlike the vast majority of other (even free to download) typefaces, which have ridiculously restricting licenses and terms of use statements. Props, Jos - you&#8217;re a pioneer, and deserve recognition as such.</p>
<a href='#fnref:1' rev='footnote'>&#8617;</a></li><li id='fn:2'>
<p>To give Microsoft a little credit, something I rarely do&#8230; Yes, I&#8217;m aware Microsoft submitted EOT to the <abbr title='World Wide Web Consortium'>W3C</abbr> as a proposal - the problem isn&#8217;t with their attempts to make it non-proprietary, but with the basic concept of making typefaces on the web DRMed. Look what such attempts have done to the music and video industry - simply decimated it. Do we really want to see the same thing happen to our beloved medium as typography moves into the 21st century?</p>
<a href='#fnref:2' rev='footnote'>&#8617;</a></li></ol></div>
*** Output of to_latex ***
-----| WARNING | -----
\hypertarget{webkit_safari_31_and_the_css_fontface_declaration}{}\section*{{WebKit (Safari 3.1) and the CSS @font-face declaration}}\label{webkit_safari_31_and_the_css_fontface_declaration}

I'{}m a big fan of typography in general. If you check out \href{http://elliottcable.name}{my homepage} or my \href{http://elliottcable.name/contact.xhtml}{contact elliottcable} page, and you'{}re using Safari/WebKit or Opera/Kestrel, you'{}ll notice the typefaces (fonts, as colloquialized) are \emph{very} non-standard. (As of this writing, I'{}m using \href{http://www.josbuivenga.demon.nl/museo.html}{Museo} and \href{http://www.josbuivenga.demon.nl/diavlo.html}{Diavlo}\footnote{These are fonts by \href{jos}{Jos Buivenga}, quite the amazing person. His (free) fonts are, uniquely, released for use on the web in {\colorbox[rgb]{1.00,0.93,1.00}{\tt \char64font\char45face}} declarations - unlike the vast majority of other (even free to download) typefaces, which have ridiculously restricting licenses and terms of use statements. Props, Jos - you'{}re a pioneer, and deserve recognition as such.}  heavily on both.)

The internet has not be a friendly place for typohiles like myself, up to this point, at least. One might even say it was a frightful, mentally scarring environment for those akin to yours truly. We'{}ve been restricted to reading page after page after page on day after day after day for year after year after year abominations of markup and design enslaved by the horrible overlords we know as Lucida, Verdana, Arial, Helvetica, Geneva, Georgia, Courier, and\ldots{} dare I invoke ye, thou my terrible overlord? Times New Roman.

Wherefore art thou, my glorious Archer? And thee as well, my beautiful Garamond? The technical restrictions of that horrible monster we know as the Web Browser hath forced us all too long to use those most banal, those most common, and those most abused, out of all of the typefaces of the world.

All hyperbole aside, I'{}m extremely happy to see the advent of a standard {\colorbox[rgb]{1.00,0.93,1.00}{\tt \char64font\char45face}} declaration in CSS. Internet Explorer first implemented a crutched, basic version of this way back in version 4, but nothing ever really came of it - their decision to create the proprietary .EOT\footnote{To give Microsoft a little credit, something I rarely do\ldots{} Yes, I'{}m aware Microsoft submitted EOT to the W3C as a proposal - the problem isn'{}t with their attempts to make it non-proprietary, but with the basic concept of making typefaces on the web DRMed. Look what such attempts have done to the music and video industry - simply decimated it. Do we really want to see the same thing happen to our beloved medium as typography moves into the 21st century?}  format to appease overly restrictive type foundries'{} worries about intellectual property (aka. the cold, hard dominatrix that we know only as Ms. Profit) truly and completely killed that initial attempt at bringing astute typography and it'{}s advocates to the web. This new run at {\colorbox[rgb]{1.00,0.93,1.00}{\tt \char64font\char45face}} by an established, trusted, and open group (the \href{http://w3c.org}{W3C} itself, responsible for helping to make much of what we use as designers on the web standard and cross-system compatible) has a much better chance, in my humble opinion - and I am quite looking forward to the consequences if it succeeds.

Now, onwards to the topic of my post as declared in the header (yes, I know, a slow start - but it'{}s an interesting topic with an interesting history!). WebKit, the open source rendering engine behind the wonderfulness that is Safari, and how it handles the `{}new'{} {\colorbox[rgb]{1.00,0.93,1.00}{\tt \char64font\char45face}} declaration. No, it'{}s not really `{}new'{}, but yes, it feels like it is.

To put it simply, and to be very blunt, it'{}s broken.

The \href{http://?}{CSS spec section} for {\colorbox[rgb]{1.00,0.93,1.00}{\tt \char64font\char45face}} is very specific - typefaces are to be selected based on a wide array of criteria placed in the {\colorbox[rgb]{1.00,0.93,1.00}{\tt \char64font\char45face}} declaration block itself. Various textual CSS attributes may be defined within the {\colorbox[rgb]{1.00,0.93,1.00}{\tt \char64font\char45face}} declaration, and then they will be checked when the typeface is referred to later in the CSS. For instance, if I have two {\colorbox[rgb]{1.00,0.93,1.00}{\tt \char64font\char45face}} declarations for the Diavlo family - one for regular text, and one for a heavier weighted version of the typeface - then I later utilize Diavlo in a {\colorbox[rgb]{1.00,0.93,1.00}{\tt font\char45family\char58}} attribute, it should refer to the basic Diavlo font defined in the first {\colorbox[rgb]{1.00,0.93,1.00}{\tt \char64font\char45face}}. However, if I were to do the same, but also specify a heavy {\colorbox[rgb]{1.00,0.93,1.00}{\tt font\char45weight\char58}}, then it should use the heavier version of Diavlo. To place this example in code:

\begin{verbatim}@font-face {
  font-family: 'Diavlo';
  src: url(./Diavlo/Diavlo_Book.otf) format("opentype");
}

@font-face {
  font-family: 'Diavlo';
  font-weight: 900;
  src: url(./Diavlo/Diavlo_Black.otf) format("opentype");
}

h1, h2, h3, h4, h5, h6 {
  font-family: 'Diavlo';
  font-weight: 900;
}

div#content {
  font-family: 'Diavlo';
}\end{verbatim}
As you can see, my headings should use the typeface defined in {\colorbox[rgb]{1.00,0.93,1.00}{\tt Diavlo\char95Black\char46otf}}, while my body content should use {\colorbox[rgb]{1.00,0.93,1.00}{\tt Diavlo\char95Book\char46otf}}. However, in WebKit, this doesn'{}t work - it completely ignores any attribute except {\colorbox[rgb]{1.00,0.93,1.00}{\tt font\char45family\char58}} and {\colorbox[rgb]{1.00,0.93,1.00}{\tt src\char58}} in a {\colorbox[rgb]{1.00,0.93,1.00}{\tt \char64font\char45face}} declaration! Completely ignores them! Not only that - not \emph{only} that - it disregards all but the last {\colorbox[rgb]{1.00,0.93,1.00}{\tt \char64font\char45face}} for a given {\colorbox[rgb]{1.00,0.93,1.00}{\tt font\char45family\char58}} attribute string!

The implication here is that, to make {\colorbox[rgb]{1.00,0.93,1.00}{\tt \char64font\char45face}} work as it is currently implemented in WebKit (and thus, Safari 3.1), I have to declare \emph{completely imaginary, non-existent type families} to satisfy WebKit alone. Here'{}s the method I have used in the places I current implement {\colorbox[rgb]{1.00,0.93,1.00}{\tt \char64font\char45face}}:

\begin{verbatim}@font-face {
  font-family: 'Diavlo Book';
  src: url(./Diavlo/Diavlo_Book.otf) format("opentype");
}

@font-face {
  font-family: 'Diavlo Black';
  src: url(./Diavlo/Diavlo_Black.otf) format("opentype");
}

h1, h2, h3, h4, h5, h6 {
  font-family: 'Diavlo Black';
}

div#content {
  font-family: 'Diavlo Book';
}\end{verbatim}
Isn'{}t it horrible? Seriously, my eyes, they bleed. There'{}s lots of problems with this far beyond the lack of semanticity when it comes to the typeface names\ldots{} let me see how many ways this breaks the purpose of {\colorbox[rgb]{1.00,0.93,1.00}{\tt \char64font\char45face}}:

\begin{itemize}%
\item You remove a large element our control over the display of the page.

As soon as we begin to use {\colorbox[rgb]{1.00,0.93,1.00}{\tt \char64font\char45face}} in our page, we can no longer make any use of any other textual control attribute - {\colorbox[rgb]{1.00,0.93,1.00}{\tt font\char45weight\char58}}, {\colorbox[rgb]{1.00,0.93,1.00}{\tt font\char45style\char58}}, and {\colorbox[rgb]{1.00,0.93,1.00}{\tt font\char45variant\char58}} are no longer available to us, because they no longer correctly map to technical typeface variant/features.

Also, many default elements are destroyed, unusable, without `{}fixing'{} - for instance, {\colorbox[rgb]{1.00,0.93,1.00}{\tt \char60b\char62}} would have no effect in a page styled for WebKit as above; We would have to specify something like {\colorbox[rgb]{1.00,0.93,1.00}{\tt b~\char123font\char45family\char58~\char39Diavlo~Black\char39\char59\char125}} - how broken is that? Unless we caught all such default elements and re-styled them to use the bastardized names instead of the correct attributes, lots of basic HTML formatting would be broken. I myself may never use in-document formatting (separation of design and content!), but what about comments forms? Forum posts? Direct HTML-literal quotes?

If we want to use Javascript to modify the display of the content, we can'{}t simply adjust the mentioned textual control attributes - we have to know and change the entire {\colorbox[rgb]{1.00,0.93,1.00}{\tt font\char45family\char58}} array of strings.


\item You make us very wet.

And by wet, I mean `{}not DRY'{}. What if we decide to change one of the bastardized font names? Or use a different font entirely? We have to go through all of our CSS, all of our Javascript, and make sure we update every occurrence of the typeface'{}s bastardized name.


\item You remove our user'{}s user choice, and waste bandwidth.

Since the names refer to families that don'{}t, in fact, exist, the browser can'{}t override the declaration with a user'{}s installed version of the typeface. This means that, regardless of whether the user already has the typeface installed on their own computer, the browser won'{}t use that - it doesn'{}t know to use `{}Diavlo'{}, which the user has installed, because it was told to use `{}Diavlo Black'{}, which no user in the entire world has installed on their computer.



\end{itemize}
This whole thing is rather worrying - I'{}ve heard Opera has {\colorbox[rgb]{1.00,0.93,1.00}{\tt \char64font\char45face}} support, though I haven'{}t had time to test this myself, so I don'{}t know if it actually does - or, for that matter, if it does it `{}correctly'{}, or has the same problems as WebKit. But either way, WebKit is one of the first two implementations to ever attempt to support {\colorbox[rgb]{1.00,0.93,1.00}{\tt \char64font\char45face}} (Microsoft'{}s unrelated {\colorbox[rgb]{1.00,0.93,1.00}{\tt \char64font\char45face}} declaration notwithstanding) - I really don'{}t want to see it'{}s early mistakes carried on to FireFox in a few years, and then Internet Explorer a few decades after that. That will leave us stuck with this broken system forever, as it has been demonstrated time and time again that if nobody else supports an old standard correctly, a newcomer to the standard will not do it correctly either. I for one would really, really, hate that.

In summary\ldots{} come on, WebKit team, this isn'{}t like you - you'{}re always the ones with the closest-to-standard implementation, and the cleanest code, and\ldots{} hell, overall? Webkit is the most secure/fastest browser available. But this is making me lose my faith in you, guys, please get it right. You'{}re pioneering a leap into the future when it comes to the Web - this is as important, or \emph{more} important, than Mosiac'{}s allowing of images was.

To put it succinctly - don'{}t fuck this up, y'{}all.
*** Output of to_md ***
-----| WARNING | -----
WebKit (Safari 3.1) and the CSS @font-face declarationI m a big fan of typography in general.
If you check out my homepageor my
contact elliottcablepage, and you re
using Safari/WebKit or Opera/Kestrel,
you ll notice the typefaces (fonts, as
colloquialized) are verynon-standard.
(As of this writing, I m using Museoand
Diavloheavily on both.)

The internet has not be a friendly
place for typohiles like myself, up to
this point, at least. One might even
say it was a frightful, mentally
scarring environment for those akin to
yours truly. We ve been restricted to
reading page after page after page on
day after day after day for year after
year after year abominations of markup
and design enslaved by the horrible
overlords we know as Lucida, Verdana,
Arial, Helvetica, Geneva, Georgia,
Courier, and dare I invoke ye, thou my
terrible overlord? Times New Roman.

Wherefore art thou, my glorious Archer?
And thee as well, my beautiful
Garamond? The technical restrictions of
that horrible monster we know as the
Web Browser hath forced us all too long
to use those most banal, those most
common, and those most abused, out of
all of the typefaces of the world.

All hyperbole aside, I m extremely
happy to see the advent of a standard
declaration in CSS. Internet Explorer
first implemented a crutched, basic
version of this way back in version 4,
but nothing ever really came of it -
their decision to create the
proprietary .EOTformat to appease
overly restrictive type foundries
worries about intellectual property
(aka. the cold, hard dominatrix that we
know only as Ms. Profit) truly and
completely killed that initial attempt
at bringing astute typography and it s
advocates to the web. This new run at
by an established, trusted, and open
group (the W3Citself, responsible for
helping to make much of what we use as
designers on the web standard and
cross-system compatible) has a much
better chance, in my humble opinion -
and I am quite looking forward to the
consequences if it succeeds.

Now, onwards to the topic of my post as
declared in the header (yes, I know, a
slow start - but it s an interesting
topic with an interesting history!).
WebKit, the open source rendering
engine behind the wonderfulness that is
Safari, and how it handles the new
declaration. No, it s not really new ,
but yes, it feels like it is.

To put it simply, and to be very blunt,
it s broken.

The CSS spec sectionfor is very
specific - typefaces are to be selected
based on a wide array of criteria
placed in the declaration block itself.
Various textual CSSattributes may be
defined within the declaration, and
then they will be checked when the
typeface is referred to later in the CSS
. For instance, if I have two
declarations for the Diavlo family -
one for regular text, and one for a
heavier weighted version of the
typeface - then I later utilize Diavlo
in a attribute, it should refer to the
basic Diavlo font defined in the first
. However, if I were to do the same,
but also specify a heavy , then it
should use the heavier version of
Diavlo. To place this example in code:

As you can see, my headings should use
the typeface defined in , while my body
content should use . However, in
WebKit, this doesn t work - it
completely ignores any attribute except
and in a declaration! Completely
ignores them! Not only that - not only
that - it disregards all but the last
for a given attribute string!

The implication here is that, to make
work as it is currently implemented in
WebKit (and thus, Safari 3.1), I have
to declare
completely imaginary, non-existent type families
to satisfy WebKit alone. Here s the
method I have used in the places I
current implement :

Isn t it horrible? Seriously, my eyes,
they bleed. There s lots of problems
with this far beyond the lack of
semanticity when it comes to the
typeface names let me see how many ways
this breaks the purpose of :

-You remove a large element our control over the display of the page.
As soon as we begin to use  in our page, we can no longer make any use of any other textual control attribute - , , and  are no longer available to us, because they no longer correctly map to technical typeface variant/features.
Also, many default elements are destroyed, unusable, without fixing - for instance,  would have no effect in a page styled for WebKit as above; We would have to specify something like  - how broken is that? Unless we caught all such default elements and re-styled them to use the bastardized names instead of the correct attributes, lots of basic HTML formatting would be broken. I myself may never use in-document formatting (separation of design and content!), but what about comments forms? Forum posts? Direct HTML-literal quotes?
If we want to use Javascript to modify the display of the content, we cant simply adjust the mentioned textual control attributes - we have to know and change the entire  array of strings.
-ou make us very wet.
And by wet, I mean not DRY. What if we decide to change one of the bastardized font names? Or use a different font entirely? We have to go through all of our CSS, all of our Javascript, and make sure we update every occurrence of the typefaces bastardized name.
-You remove our users user choice, and waste bandwidth.
Since the names refer to families that dont, in fact, exist, the browser cant override the declaration with a users installed version of the typeface. This means that, regardless of whether the user already has the typeface installed on their own computer, the browser wont use that - it doesnt know to use Diavlo, which the user has installed, because it was told to use Diavlo Black, which no user in the entire world has installed on their computer.

This whole thing is rather worrying - I
ve heard Opera has support, though I
haven t had time to test this myself,
so I don t know if it actually does -
or, for that matter, if it does it
correctly , or has the same problems as
WebKit. But either way, WebKit is one
of the first two implementations to
ever attempt to support (Microsoft s
unrelated declaration notwithstanding)
- I really don t want to see it s early
mistakes carried on to FireFox in a few
years, and then Internet Explorer a few
decades after that. That will leave us
stuck with this broken system forever,
as it has been demonstrated time and
time again that if nobody else supports
an old standard correctly, a newcomer
to the standard will not do it
correctly either. I for one would
really, really, hate that.

In summary come on, WebKit team, this
isn t like you - you re always the ones
with the closest-to-standard
implementation, and the cleanest code,
and hell, overall? Webkit is the most
secure/fastest browser available. But
this is making me lose my faith in you,
guys, please get it right. You re
pioneering a leap into the future when
it comes to the Web - this is as
important, or moreimportant, than
Mosiac s allowing of images was.

To put it succinctly - don t fuck this
up, y all.

These are fonts by Jos Buivenga, quite
the amazing person. His (free) fonts
are, uniquely, released for use on the
web in declarations - unlike the vast
majority of other (even free to
download) typefaces, which have
ridiculously restricting licenses and
terms of use statements. Props, Jos -
you re a pioneer, and deserve
recognition as such.

*[CSS]: Cascading Style Sheets
*[.EOT]: Embedded OpenType
To give Microsoft a little credit,
something I rarely do Yes, I m aware
Microsoft submitted EOT to the W3Cas a
proposal - the problem isn t with their
attempts to make it non-proprietary,
but with the basic concept of making
typefaces on the web DRMed. Look what
such attempts have done to the music
and video industry - simply decimated
it. Do we really want to see the same
thing happen to our beloved medium as
typography moves into the 21st century?

*[W3C]: World Wide Web Consortium
*[DRY]: Don't Repeat Yourself
*** Output of to_s ***
-----| WARNING | -----
WebKit (Safari 3.1) and the CSS @font-face declarationIm a big fan of typography in general. If you check out my homepage or my contact elliottcable page, and youre using Safari/WebKit or Opera/Kestrel, youll notice the typefaces (fonts, as colloquialized) are very non-standard. (As of this writing, Im using Museo and Diavlo heavily on both.)The internet has not be a friendly place for typohiles like myself, up to this point, at least. One might even say it was a frightful, mentally scarring environment for those akin to yours truly. Weve been restricted to reading page after page after page on day after day after day for year after year after year abominations of markup and design enslaved by the horrible overlords we know as Lucida, Verdana, Arial, Helvetica, Geneva, Georgia, Courier, and dare I invoke ye, thou my terrible overlord? Times New Roman.Wherefore art thou, my glorious Archer? And thee as well, my beautiful Garamond? The technical restrictions of that horrible monster we know as the Web Browser hath forced us all too long to use those most banal, those most common, and those most abused, out of all of the typefaces of the world.All hyperbole aside, Im extremely happy to see the advent of a standard  declaration in CSS. Internet Explorer first implemented a crutched, basic version of this way back in version 4, but nothing ever really came of it - their decision to create the proprietary .EOT format to appease overly restrictive type foundries worries about intellectual property (aka. the cold, hard dominatrix that we know only as Ms. Profit) truly and completely killed that initial attempt at bringing astute typography and its advocates to the web. This new run at  by an established, trusted, and open group (the W3C itself, responsible for helping to make much of what we use as designers on the web standard and cross-system compatible) has a much better chance, in my humble opinion - and I am quite looking forward to the consequences if it succeeds.Now, onwards to the topic of my post as declared in the header (yes, I know, a slow start - but its an interesting topic with an interesting history!). WebKit, the open source rendering engine behind the wonderfulness that is Safari, and how it handles the new  declaration. No, its not really new, but yes, it feels like it is.To put it simply, and to be very blunt, its broken.The CSS spec section for  is very specific - typefaces are to be selected based on a wide array of criteria placed in the  declaration block itself. Various textual CSS attributes may be defined within the  declaration, and then they will be checked when the typeface is referred to later in the CSS. For instance, if I have two  declarations for the Diavlo family - one for regular text, and one for a heavier weighted version of the typeface - then I later utilize Diavlo in a  attribute, it should refer to the basic Diavlo font defined in the first . However, if I were to do the same, but also specify a heavy , then it should use the heavier version of Diavlo. To place this example in code:As you can see, my headings should use the typeface defined in , while my body content should use . However, in WebKit, this doesnt work - it completely ignores any attribute except  and  in a  declaration! Completely ignores them! Not only that - not only that - it disregards all but the last  for a given  attribute string!The implication here is that, to make  work as it is currently implemented in WebKit (and thus, Safari 3.1), I have to declare completely imaginary, non-existent type families to satisfy WebKit alone. Heres the method I have used in the places I current implement :Isnt it horrible? Seriously, my eyes, they bleed. Theres lots of problems with this far beyond the lack of semanticity when it comes to the typeface names let me see how many ways this breaks the purpose of :You remove a large element our control over the display of the page.As soon as we begin to use  in our page, we can no longer make any use of any other textual control attribute - , , and  are no longer available to us, because they no longer correctly map to technical typeface variant/features.Also, many default elements are destroyed, unusable, without fixing - for instance,  would have no effect in a page styled for WebKit as above; We would have to specify something like  - how broken is that? Unless we caught all such default elements and re-styled them to use the bastardized names instead of the correct attributes, lots of basic HTML formatting would be broken. I myself may never use in-document formatting (separation of design and content!), but what about comments forms? Forum posts? Direct HTML-literal quotes?If we want to use Javascript to modify the display of the content, we cant simply adjust the mentioned textual control attributes - we have to know and change the entire  array of strings.You make us very wet.And by wet, I mean not DRY. What if we decide to change one of the bastardized font names? Or use a different font entirely? We have to go through all of our CSS, all of our Javascript, and make sure we update every occurrence of the typefaces bastardized name.You remove our users user choice, and waste bandwidth.Since the names refer to families that dont, in fact, exist, the browser cant override the declaration with a users installed version of the typeface. This means that, regardless of whether the user already has the typeface installed on their own computer, the browser wont use that - it doesnt know to use Diavlo, which the user has installed, because it was told to use Diavlo Black, which no user in the entire world has installed on their computer.This whole thing is rather worrying - Ive heard Opera has  support, though I havent had time to test this myself, so I dont know if it actually does - or, for that matter, if it does it correctly, or has the same problems as WebKit. But either way, WebKit is one of the first two implementations to ever attempt to support  (Microsofts unrelated  declaration notwithstanding) - I really dont want to see its early mistakes carried on to FireFox in a few years, and then Internet Explorer a few decades after that. That will leave us stuck with this broken system forever, as it has been demonstrated time and time again that if nobody else supports an old standard correctly, a newcomer to the standard will not do it correctly either. I for one would really, really, hate that.In summary come on, WebKit team, this isnt like you - youre always the ones with the closest-to-standard implementation, and the cleanest code, and hell, overall? Webkit is the most secure/fastest browser available. But this is making me lose my faith in you, guys, please get it right. Youre pioneering a leap into the future when it comes to the Web - this is as important, or more important, than Mosiacs allowing of images was.To put it succinctly - dont fuck this up, yall.These are fonts by Jos Buivenga, quite the amazing person. His (free) fonts are, uniquely, released for use on the web in  declarations - unlike the vast majority of other (even free to download) typefaces, which have ridiculously restricting licenses and terms of use statements. Props, Jos - youre a pioneer, and deserve recognition as such.To give Microsoft a little credit, something I rarely do Yes, Im aware Microsoft submitted EOT to the W3C as a proposal - the problem isnt with their attempts to make it non-proprietary, but with the basic concept of making typefaces on the web DRMed. Look what such attempts have done to the music and video industry - simply decimated it. Do we really want to see the same thing happen to our beloved medium as typography moves into the 21st century?
*** Output of Markdown.pl ***
(not used anymore)
*** Output of Markdown.pl (parsed) ***
(not used anymore)