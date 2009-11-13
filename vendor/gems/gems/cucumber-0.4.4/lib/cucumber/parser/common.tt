module Cucumber
  module Parser
    grammar Common
      rule white
        (space / eol)*
      end

      rule space
        [ \t]
      end

      rule eol
        "\n" / ("\r" "\n"?)
      end

      rule eof
        !.
      end
    end
  end
end