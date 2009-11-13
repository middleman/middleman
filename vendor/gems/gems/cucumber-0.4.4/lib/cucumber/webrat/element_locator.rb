require 'webrat'

module Webrat
  class Element
    # Returns an Array of Array of String where each String is a
    # "cell" in the table-like structure represented by this Element.
    #
    # Supported elements are table, dl, ol and ul. Different conversion
    # strategies are used depending on the kind of element:
    #
    # * table    : Each tr becomes a row. The innerHTML of each td or th inside becomes a cell. The number 
    #              of columns is determined by the number of cells in the first row.
    # * dl       : Each dt becomes a row with 2 cells. The innerHTML of the dt itself and the next dd become cells.
    # * ul or ol : Each li becomes a row with one cell, the innerHTML of the li.
    #
    def to_table
      case element.name
      when 'table'
        table_from_table
      when 'dl'
        table_from_dl
      when /ul|ol/
        table_from_list
      else
        raise "#to_table not supported for #{element.name} elements"
      end
    end
    
    def table_from_table #:nodoc:
      col_count = nil
      Webrat::XML.css_search(element, 'tr').map do |row|
        cols = Webrat::XML.css_search(row, 'th,td')
        col_count ||= cols.length
        cols[0...col_count].map do |col|
          col.inner_html
        end
      end
    end

    def table_from_dl #:nodoc:
      Webrat::XML.css_search(@element, 'dt').map do |dt|
        next_node = dt.next_sibling
        while next_node.name != 'dd'
          next_node = next_node.next_sibling
        end
        [dt.inner_html, next_node.inner_html]
      end
    end

    def table_from_list #:nodoc:
      Webrat::XML.css_search(@element, 'li').map do |li|
        [li.inner_html]
      end
    end

    alias to_a to_table # Backwards compatibility with Cucumber
  end
  
  module Locators
    class ElementLocator < Locator #:nodoc:
      def locate
        Element.load(@session, table_element)
      end

      def table_element
        Webrat::XML.css_search(@dom, @value)[0]
      end

      def error_message
        "Could not find anything matching '#{@value}'"
      end
    end

    # Returns a Webrat DOM element located by +css_selector+.
    def element_at(css_selector)
      ElementLocator.new(@session, dom, css_selector).locate!
    end
    
    alias table_at element_at # Backwards compatibility with Cucumber
  end
  
  module Methods #:nodoc:
    delegate_to_session :element_at, :table_at
  end
  
  class Session #:nodoc:
    def_delegators :current_scope, :element_at, :table_at
  end
end
