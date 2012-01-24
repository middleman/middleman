#--
# Copyright (c) 2008 Ryan Grove <ryan@wonko.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#   * Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#   * Neither the name of this project nor the names of its contributors may be
#     used to endorse or promote products derived from this software without
#     specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#++

# Minify CSS
module CSSMin
  
  # Compress a CSS string
  # @param [String] input
  # @return [String]
  def self.compress(input)
    css = input.is_a?(IO) ? input.read : input.dup.to_s
    css.gsub!(/\/\*[\s\S]*?\*\//, '')
    css.gsub!(/\s+/, ' ')
    css.gsub!(/"\\"\}\\""/, '___BMH___')
    css.gsub!(/(?:^|\})[^\{:]+\s+:+[^\{]*\{/) do |match|
      match.gsub(':', '___PSEUDOCLASSCOLON___')
    end
    css.gsub!(/\s+([!\{\};:>+\(\)\],])/, '\1')
    css.gsub!('___PSEUDOCLASSCOLON___', ':')
    css.gsub!(/([!\{\}:;>+\(\[,])\s+/, '\1')
    css.gsub!(/([^;\}])\}/, '\1;}')
    css.gsub!(/([\s:])([+-]?0)(?:%|em|ex|px|in|cm|mm|pt|pc)/i, '\1\2')
    css.gsub!(/:(?:0 )+0;/, ':0;')
    css.gsub!('background-position:0;', 'background-position:0 0;')
    css.gsub!(/(:|\s)0+\.(\d+)/, '\1.\2')
    css.gsub!(/rgb\s*\(\s*([0-9,\s]+)\s*\)/) do |match|
      '#' << $1.scan(/\d+/).map{|n| n.to_i.to_s(16).rjust(2, '0') }.join
    end
    css.gsub!(/([^"'=\s])\s*#([0-9a-f])\2([0-9a-f])\3([0-9a-f])\4/i, '\1 #\2\3\4')
    css.gsub!(/[^\}]+\{;\}\n/, '')
    css.gsub!('___BMH___', '"\"}\""')
    css.gsub!(/;;+/, ';')
    css.strip
  end
end