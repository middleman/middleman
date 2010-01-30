When no framework is specified, a new compass project is set up with three stylesheets:

* screen.sass
* print.sass
* ie.sass

It is expected that you will link your html to these like so:

    <head>
      <link href="/stylesheets/screen.css" media="screen, projection"
            rel="stylesheet" type="text/css" />
      <link href="/stylesheets/print.css" media="print"
            rel="stylesheet" type="text/css" />
      <!--[if IE]>
          <link href="/stylesheets/ie.css" media="screen, projection"
                rel="stylesheet" type="text/css" />
      <![endif]-->
    </head>

You don't have to use these three stylesheets, they are just a recommendation.
You can rename them, make new stylesheets, and delete them. Compass will
happily compile whatever sass files you place into your project.

Any folders you create in your source directory with sass files in them will be folders
that get created with css files in them when compiled.

Sass files beginning with an underscore are called partials, they are not directly
compiled to their own css file. You can use these partials by importing them
into other stylesheets. This is useful for keeping your stylesheets small and manageable
and single-focused. It is common to create a file called _base.sass at the top level
of your stylesheets and to import this to set up project-wide constants and mixins.

