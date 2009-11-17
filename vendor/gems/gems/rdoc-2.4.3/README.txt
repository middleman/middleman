= \RDoc

* {RDoc Project Page}[http://rubyforge.org/projects/rdoc/]
* {RDoc Documentation}[http://rdoc.rubyforge.org/]
* {RDoc Bug Tracker}[http://rubyforge.org/tracker/?atid=2472&group_id=627&func=browse]

== DESCRIPTION:

RDoc is an application that produces documentation for one or more Ruby source
files.  RDoc includes the +rdoc+ and +ri+ tools for generating and displaying
online documentation.

At this point in time, RDoc 2.x is a work in progress and may incur further
API changes beyond what has been made to RDoc 1.0.1.  Command-line tools are
largely unaffected, but internal APIs may shift rapidly.

See RDoc for a description of RDoc's markup and basic use.

== SYNOPSIS:

  gem 'rdoc'
  require 'rdoc/rdoc'
  # ... see RDoc

== BUGS:

The markup engine has lots of little bugs.  In particular:
* Escaping does not work for all markup.
* Typesetting is not always correct.
* Some output formats (ri, for example) do not correctly handle all of the
  markup.

RDoc has some subtle bugs processing classes that are split across multiple
files (bugs that may or may not manifest depending on the order in which
the files are encountered).  This issue can be tracked here[http://rubyforge.org/tracker/index.php?func=detail&aid=22135&group_id=627&atid=2475].

If you find a bug, please report it at the RDoc project's
tracker[http://rubyforge.org/tracker/?group_id=627] on RubyForge:

== LICENSE:

RDoc is Copyright (c) 2001-2003 Dave Thomas, The Pragmatic Programmers.
Portions (c) 2007-2009 Eric Hodel.  Portions copyright others, see individual
files for details.

It is free software, and may be redistributed under the terms specified in the
README file of the Ruby distribution.
