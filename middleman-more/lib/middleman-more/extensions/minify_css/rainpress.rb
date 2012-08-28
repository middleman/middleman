# == Information
#
# This is the main class of Rainpress, create an instance of it to compress
# your CSS-styles.
#
# Author:: Uwe L. Korn <uwelk@xhochy.org>
#
# <b>Options:</b>
#
# * <tt>:comments</tt> - if set to false, comments will not be removed
# * <tt>:newlines</tt> - if set to false, newlines will not be removed
# * <tt>:spaces</tt> - if set to false, spaces will not be removed
# * <tt>:colors</tt> - if set to false, colors will not be modified
# * <tt>:misc</tt> - if set to false, miscellaneous compression parts will be skipped
class Rainpress
  # Quick-compress the styles.
  # This eliminates the need to create an instance of the class
  def self.compress(style, options = {})
    self.new(style, options).compress!
  end

  def initialize(style, opts = {})
    @style = style
    @opts = {
      :comments => true,
      :newlines => true,
      :spaces   => true,
      :colors   => false,
      :misc     => true
    }
    @opts.merge! opts
  end

  # Run the compressions and return the newly compressed text
  def compress!
    remove_comments!  if @opts[:comments]
    remove_newlines!  if @opts[:newlines]
    remove_spaces!    if @opts[:spaces]
    shorten_colors!   if @opts[:colors]
    do_misc!          if @opts[:misc]
    @style
  end

  # Remove all comments out of the CSS-Document
  #
  # Only /* text */ comments are supported.
  # Attention: If you are doing css hacks for IE using the comment tricks,
  # they will be removed using this function. Please consider for IE css style
  # corrections the usage of conditionals comments in your (X)HTML document.
	def remove_comments!
    input = @style
    @style = ''

    while input.length > 0 do
      pos = input.index("/*");

      # No more comments
      if pos == nil
        @style += input
        input = '';
      else # Comment beginning at pos
        @style += input[0..(pos-1)] if pos > 0 # only append text if there is some
        input = input[(pos+2)..-1]
        # Comment ending at pos
        pos = input.index("*/")
        input = input[(pos+2)..-1]
      end
    end
	end

  # Remove all newline characters
  #
  # We take care of Windows(\r\n), Unix(\n) and Mac(\r) newlines.
	def remove_newlines!
		@style.gsub! /\n|\r/, ''
	end

	# Remove unneeded spaces
	#
  # 1. Turn mutiple spaces into a single
  # 2. Remove spaces around ;:{},
  # 3. Remove tabs
  def remove_spaces!
    @style.gsub! /\s*(\s|;|:|\}|\{|,)\s*/, '\1'
    @style.gsub! "\t", ''
	end

	# Replace color values with their shorter equivalent
	#
	# 1. Turn rgb(,,)-colors into #-values
	# 2. Shorten #AABBCC down to #ABC
	# 3. Replace names with their shorter hex-equivalent
	#    * white -> #fff
 	#    * black -> #000
	# 4. Replace #-values with their shorter name
	#    * #f00 -> red
	def shorten_colors!
	  # rgb(50,101,152) to #326598
    @style.gsub! /rgb\s*\(\s*([0-9,\s]+)\s*\)/ do |match|
      out = '#'
      $1.split(',').each do |num|
        out += '0' if num.to_i < 16
        out += num.to_i.to_s(16) # convert to hex
      end
      out
    end
    # Convert #AABBCC to #ABC, keep if preceed by a '='
    @style.gsub! /([^\"'=\s])(\s*)#([\da-f])\3([\da-f])\4([\da-f])\5/i, '\1#\3\4\5'

    # At the moment we assume that colours only appear before ';' or '}' and
    # after a ':', if there could be an occurence of a color before or after
    # an other character, submit either a bug report or, better, a patch that
    # enables Rainpress to take care of this.

    # shorten several names to numbers
    ## shorten white -> #fff
    @style.gsub! /:\s*white\s*(;|\})/, ':#fff\1'

    ## shorten black -> #000
    @style.gsub! /:\s*black\s*(;|\})/, ':#000\1'

    # shotern several numbers to names
    ## shorten #f00 or #ff0000 -> red
    @style.gsub! /:\s*#f{1,2}0{2,4}(;|\})/i, ':red\1'
  end

  # Do miscellaneous compression methods on the style.
  def do_misc!
    # Replace 0(pt,px,em,%) with 0 but only when preceded by : or a white-space
    @style.gsub! /([\s:]+)(0)(px|em|%|in|cm|mm|pc|pt|ex)/i, '\1\2'

    # Replace :0 0 0 0(;|}) with :0(;|})
    @style.gsub! /:0 0 0 0(;|\})/, ':0\1'

    # Replace :0 0 0(;|}) with :0(;|})
    @style.gsub! /:0 0 0(;|\})/, ':0\1'

    # Replace :0 0(;|}) with :0(;|})
    @style.gsub! /:0 0(;|\})/, ':0\1'

    # Replace background-position:0; with background-position:0 0;
    @style.gsub! 'background-position:0;', 'background-position:0 0;'

    # Replace 0.6 to .6, but only when preceded by : or a white-space
    @style.gsub! /[:\s]0+\.(\d+)/ do |match|
      match.sub '0', '' # only first '0' !!
    end

    # Replace multiple ';' with a single ';'
    @style.gsub! /[;]+/, ';'

    # Replace ;} with }
    @style.gsub! ';}', '}'

    # Replace font-weight:normal; with 400
    @style.gsub! /font-weight[\s]*:[\s]*normal[\s]*(;|\})/i,'font-weight:400\1'
    @style.gsub! /font[\s]*:[\s]*normal[\s;\}]*/ do |match|
      match.sub 'normal', '400'
    end

    # Replace font-weight:bold; with 700
    @style.gsub! /font-weight[\s]*:[\s]*bold[\s]*(;|\})/,'font-weight:700\1'
    @style.gsub! /font[\s]*:[\s]*bold[\s;\}]*/ do |match|
      match.sub 'bold', '700'
    end
  end

end
