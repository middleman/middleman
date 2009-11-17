module Markaby

  FORM_TAGS = [ :form, :input, :select, :textarea ]
  SELF_CLOSING_TAGS = [ :base, :meta, :link, :hr, :br, :param, :img, :area, :input, :col ]
  NO_PROXY = [ :hr, :br ]

  # Common sets of attributes.
  AttrCore = [:id, :class, :style, :title]
  AttrI18n = [:lang, 'xml:lang'.intern, :dir]
  AttrEvents = [:onclick, :ondblclick, :onmousedown, :onmouseup, :onmouseover, :onmousemove, 
      :onmouseout, :onkeypress, :onkeydown, :onkeyup]
  AttrFocus = [:accesskey, :tabindex, :onfocus, :onblur]
  AttrHAlign = [:align, :char, :charoff]
  AttrVAlign = [:valign]
  Attrs = AttrCore + AttrI18n + AttrEvents

  # All the tags and attributes from XHTML 1.0 Strict
  class XHTMLStrict
    class << self
      attr_accessor :tags, :tagset, :forms, :self_closing, :doctype
    end
    @doctype = ["-//W3C//DTD XHTML 1.0 Strict//EN", "DTD/xhtml1-strict.dtd"]
    @tagset = {
      :html => AttrI18n + [:id, :xmlns],
      :head => AttrI18n + [:id, :profile],
      :title => AttrI18n + [:id],
      :base => [:href, :id],
      :meta => AttrI18n + [:id, :http, :name, :content, :scheme, 'http-equiv'.intern],
      :link => Attrs + [:charset, :href, :hreflang, :type, :rel, :rev, :media],
      :style => AttrI18n + [:id, :type, :media, :title, 'xml:space'.intern],
      :script => [:id, :charset, :type, :src, :defer, 'xml:space'.intern],
      :noscript => Attrs,
      :body => Attrs + [:onload, :onunload],
      :div => Attrs,
      :p => Attrs,
      :ul => Attrs,
      :ol => Attrs,
      :li => Attrs,
      :dl => Attrs,
      :dt => Attrs,
      :dd => Attrs,
      :address => Attrs,
      :hr => Attrs,
      :pre => Attrs + ['xml:space'.intern],
      :blockquote => Attrs + [:cite],
      :ins => Attrs + [:cite, :datetime],
      :del => Attrs + [:cite, :datetime],
      :a => Attrs + AttrFocus + [:charset, :type, :name, :href, :hreflang, :rel, :rev, :shape, :coords],
      :span => Attrs,
      :bdo => AttrCore + AttrEvents + [:lang, 'xml:lang'.intern, :dir],
      :br => AttrCore,
      :em => Attrs,
      :strong => Attrs,
      :dfn => Attrs,
      :code => Attrs,
      :samp => Attrs,
      :kbd => Attrs,
      :var => Attrs,
      :cite => Attrs,
      :abbr => Attrs,
      :acronym => Attrs,
      :q => Attrs + [:cite],
      :sub => Attrs,
      :sup => Attrs,
      :tt => Attrs,
      :i => Attrs,
      :b => Attrs,
      :big => Attrs,
      :small => Attrs,
      :object => Attrs + [:declare, :classid, :codebase, :data, :type, :codetype, :archive, :standby, :height, :width, :usemap, :name, :tabindex],
      :param => [:id, :name, :value, :valuetype, :type],
      :img => Attrs + [:src, :alt, :longdesc, :height, :width, :usemap, :ismap],
      :map => AttrI18n + AttrEvents + [:id, :class, :style, :title, :name],
      :area => Attrs + AttrFocus + [:shape, :coords, :href, :nohref, :alt],
      :form => Attrs + [:action, :method, :enctype, :onsubmit, :onreset, :accept, :accept],
      :label => Attrs + [:for, :accesskey, :onfocus, :onblur],
      :input => Attrs + AttrFocus + [:type, :name, :value, :checked, :disabled, :readonly, :size, :maxlength, :src, :alt, :usemap, :onselect, :onchange, :accept],
      :select => Attrs + [:name, :size, :multiple, :disabled, :tabindex, :onfocus, :onblur, :onchange],
      :optgroup => Attrs + [:disabled, :label],
      :option => Attrs + [:selected, :disabled, :label, :value],
      :textarea => Attrs + AttrFocus + [:name, :rows, :cols, :disabled, :readonly, :onselect, :onchange],
      :fieldset => Attrs,
      :legend => Attrs + [:accesskey],
      :button => Attrs + AttrFocus + [:name, :value, :type, :disabled],
      :table => Attrs + [:summary, :width, :border, :frame, :rules, :cellspacing, :cellpadding],
      :caption => Attrs,
      :colgroup => Attrs + AttrHAlign + AttrVAlign + [:span, :width],
      :col => Attrs + AttrHAlign + AttrVAlign + [:span, :width],
      :thead => Attrs + AttrHAlign + AttrVAlign,
      :tfoot => Attrs + AttrHAlign + AttrVAlign,
      :tbody => Attrs + AttrHAlign + AttrVAlign,
      :tr => Attrs + AttrHAlign + AttrVAlign,
      :th => Attrs + AttrHAlign + AttrVAlign + [:abbr, :axis, :headers, :scope, :rowspan, :colspan],
      :td => Attrs + AttrHAlign + AttrVAlign + [:abbr, :axis, :headers, :scope, :rowspan, :colspan],
      :h1 => Attrs,
      :h2 => Attrs,
      :h3 => Attrs,
      :h4 => Attrs,
      :h5 => Attrs,
      :h6 => Attrs
    }

    @tags = @tagset.keys
    @forms = @tags & FORM_TAGS
    @self_closing = @tags & SELF_CLOSING_TAGS
  end

  # Additional tags found in XHTML 1.0 Transitional
  class XHTMLTransitional
    class << self
      attr_accessor :tags, :tagset, :forms, :self_closing, :doctype
    end
    @doctype = ["-//W3C//DTD XHTML 1.0 Transitional//EN", "DTD/xhtml1-transitional.dtd"]
    @tagset = XHTMLStrict.tagset.merge \
      :strike => Attrs,
      :center => Attrs,
      :dir => Attrs + [:compact], 
      :noframes => Attrs,
      :basefont => [:id, :size, :color, :face], 
      :u => Attrs,
      :menu => Attrs + [:compact], 
      :iframe => AttrCore + [:longdesc, :name, :src, :frameborder, :marginwidth, :marginheight, :scrolling, :align, :height, :width],
      :font => AttrCore + AttrI18n + [:size, :color, :face],
      :s => Attrs,
      :applet => AttrCore + [:codebase, :archive, :code, :object, :alt, :name, :width, :height, :align, :hspace, :vspace],
      :isindex => AttrCore + AttrI18n + [:prompt]

    # Additional attributes found in XHTML 1.0 Transitional
    { :script => [:language],
      :a => [:target],
      :td => [:bgcolor, :nowrap, :width, :height],
      :p => [:align],
      :h5 => [:align],
      :h3 => [:align],
      :li => [:type, :value],
      :div => [:align],
      :pre => [:width],
      :body => [:background, :bgcolor, :text, :link, :vlink, :alink],
      :ol => [:type, :compact, :start],
      :h4 => [:align],
      :h2 => [:align],
      :object => [:align, :border, :hspace, :vspace],
      :img => [:name, :align, :border, :hspace, :vspace],
      :link => [:target],
      :legend => [:align],
      :dl => [:compact],
      :input => [:align],
      :h6 => [:align],
      :hr => [:align, :noshade, :size, :width],
      :base => [:target],
      :ul => [:type, :compact],
      :br => [:clear],
      :form => [:name, :target],
      :area => [:target],
      :h1 => [:align]
    }.each do |k, v|
        @tagset[k] += v
    end

    @tags = @tagset.keys
    @forms = @tags & FORM_TAGS
    @self_closing = @tags & SELF_CLOSING_TAGS
  end

end
