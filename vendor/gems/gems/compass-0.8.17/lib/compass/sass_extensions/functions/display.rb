module Compass::SassExtensions::Functions::Display
  DEFAULT_DISPLAY = {
    :block => %w{address blockquote center dir div dd dl dt fieldset form
                 frameset h1 h2 h3 h4 h5 h6 hr isindex menu noframes
                 noscript ol p pre ul},
    :inline => %w{a abbr acronym b basefont bdo big br cite code dfn em
                  font i img input kbd label q s samp select small span
                  strike strong sub sup textarea tt u var},
    :table => %w{table},
    :"list-item" => %w{li},
    :"table-row-group" => %w{tbody},
    :"table-header-group" => %w{thead},
    :"table-footer-group" => %w{tfoot},
    :"table-row" => %w{tr},
    :"table-cell" => %w{th td}
  }

  # returns a comma delimited string for all the elements according to their default css3 display value.
  def elements_of_type(display)
    Sass::Script::String.new(DEFAULT_DISPLAY.fetch(display.value.to_sym).join(", "))
  end
end