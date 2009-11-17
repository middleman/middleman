module Cucumber
  module Parser
    # TIP: When you hack on the grammar, just delete table.rb in this directory.
    # Also make sure you have uninstalled all cucumber gems (don't forget xxx-cucumber
    # github gems).
    #
    # Treetop will then generate the parser in-memory. When you're happy, just generate
    # the rb file with tt feature.tt
    grammar Table
      include Common

      rule table
        table_row+ {
          def at_line?(line)
            elements.detect{|table_row| table_row.at_line?(line)}
          end

          def build(filter=nil)
            Ast::Table.new(raw)
          end

          def raw(filter=nil, scenario_outline=nil)
            elements.map do |table_row|
              if(filter.nil? || table_row == elements[0] || filter.at_line?(table_row) || (scenario_outline && filter.outline_at_line?(scenario_outline)))
                table_row.build
              end
            end.compact
          end
        }
      end

      rule table_row
        space* '|' cells:(cell '|')+ space* (eol+ / eof) {
          def at_line?(line)
            cells.line == line
          end

          def build
            row = cells.elements.map do |elt| 
              value = elt.cell.text_value.strip
              value
            end

            class << row
              attr_accessor :line
            end
            row.line = cells.line

            row
          end
        }
      end

      rule cell
        (!('|' / eol) .)*
      end

    end
  end
end