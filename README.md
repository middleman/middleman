# Middleman - Makes developing websites simple

[![Gem Version](http://img.shields.io/gem/v/middleman.svg?style=flat)][gem]
[![License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)][license]

**Middleman** is a static site generator using all the shortcuts and tools in modern web development. Check out [middlemanapp.com](https://middlemanapp.com/) for detailed tutorials, including a [getting started guide](https://middlemanapp.com/basics/getting-started/). You can also follow [@middlemanapp](https://twitter.com/middlemanapp) for updates.

## Why Middleman?

These days, many websites are built with an API in mind. Rather than package the frontend and the backend together, both can be built and deployed independently using the public API to pull data from the backend and display it on the frontend. Static websites are incredibly fast and require very little RAM. A front-end built to stand-alone can be deployed directly to the cloud or a CDN. Many designers and developers simply deliver static HTML/JS/CSS to their clients.

- Uses [Sass](https://sass-lang.com/) for DRY stylesheets.
- Bring your own asset pipeline (WebPack, Babel, Sprockets or any other).
- Easy templating with [ERb](https://ruby-doc.org/stdlib-2.0.0/libdoc/erb/rdoc/ERB.html) or [Haml](https://haml.info/).

**Middleman** gives the stand-alone developer access to all these tools and many, many more.

## Installation

Middleman is built on Ruby and uses the RubyGems package manager for installation. These are usually pre-installed on Mac OS X and Linux. Windows users can install both using [RubyInstaller]. For windows [RubyInstaller-Devkit] is also required.

```
gem install middleman
```

## Getting Started

Once Middleman is installed, you will have access to the `middleman` command. First, let's create a new project. From the terminal:

```
middleman init MY_PROJECT
```

This will create a new Middleman project located in the "MY_PROJECT" directory. This project contains a `config.rb` file for configuring Middleman and a `source` directory for storing your pages, stylesheets, javascripts and images.

Change directories into your new project and start the preview server:

```
cd MY_PROJECT
middleman server
```

The preview server allows you to build your site, by modifying the contents of the `source` directory, and see your changes reflected in the browser at: `http://localhost:4567/`

To get started, simply develop as you normally would by building HTML, CSS, and JavaScript in the `source` directory. When you're ready to use more complex templates, simply add the templating engine's extension to the file and start writing in that format.

For example, say I am working on a stylesheet at `source/stylesheets/site.css` and I'd like to start using Sass. I would rename the file to `source/stylesheets/site.css.scss` and Middleman will automatically begin processing that file as Sass. The same would apply to CoffeeScript (`.js.coffee`), Haml (`.html.haml`) and any other templating engine you might want to use.

Finally, you will want to build your project into a stand-alone site. From the project directory:

```
middleman build
```

This will compile your templates and output a stand-alone site which can be easily hosted or delivered to your client. The build step can also compress images, employ JavaScript & CSS dependency management, minify JavaScript & CSS and run additional code of your choice. Take a look at the `config.rb` file to see some of the most common extensions which can be activated.

## Learn More

A full set of in-depth instructional guides are available on the official website at: https://middlemanapp.com

Additionally, up-to-date generated code documentation is available on [RubyDoc]

## Community

The official community forum is available at: https://forum.middlemanapp.com

## Contributing to Middleman

Contributions are welcomed! To get started, please see our [contribution guidelines](https://github.com/middleman/middleman/blob/master/.github/CONTRIBUTING.md), which include information on [submitting bug reports](https://github.com/middleman/middleman/blob/master/.github/CONTRIBUTING.md#submitting-an-issue), and [running the tests](https://github.com/middleman/middleman/blob/master/.github/CONTRIBUTING.md#testing).

## Donate

[Click here to lend your support to Middleman](https://plasso.co/s/4dXbHBorC3)

## Versioning

This library aims to adhere to [Semantic Versioning 2.0.0][semver]. Violations
of this scheme should be reported as bugs. Specifically, if a minor or patch
version is released that breaks backward compatibility, that version should be
immediately yanked and/or a new version should be immediately released that
restores compatibility. Breaking changes to the public API will only be
introduced with new major versions. As a result of this policy, you can (and
should) specify a dependency on this gem using the [Pessimistic Version
Constraint][pvc] with two digits of precision. For example:

    spec.add_dependency 'middleman-core', '~> 4.0'

[semver]: https://semver.org/
[pvc]: https://guides.rubygems.org/patterns/#pessimistic-version-constraint

## License

Copyright (c) 2010-today Thomas Reynolds. MIT Licensed, see [LICENSE] for details.

[middleman]: https://middlemanapp.com
[gem]: https://rubygems.org/gems/middleman
[gittip]: https://www.gittip.com/middleman/
[rubyinstaller]: https://rubyinstaller.org/
[rubyinstaller-devkit]: https://rubyinstaller.org/add-ons/devkit.html
[rubydoc]: https://rubydoc.info/github/middleman/middleman
[license]: https://github.com/middleman/middleman/blob/master/LICENSE.md
[gitter]: https://gitter.im/middleman/middleman?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge
