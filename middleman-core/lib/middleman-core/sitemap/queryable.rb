require "active_support/core_ext/object/inclusion"

module Middleman
  module Sitemap
    
    # Code adapted from https://github.com/ralph/document_mapper/
    module Queryable
      OPERATOR_MAPPING = {
        'equal'   => :==,
        'gt'      => :>,
        'gte'     => :>=,
        'in'      => :in?,
        'include' => :include?,
        'lt'      => :<,
        'lte'     => :<=
      }

      VALID_OPERATORS = OPERATOR_MAPPING.keys

      FileNotFoundError = Class.new StandardError
      OperatorNotSupportedError = Class.new StandardError

      module API
        def select(options = {})
          documents = resources.select { |r| !r.raw_data.empty? }
          options[:where].each do |selector, selector_value|
            documents = documents.select do |document|
              next unless document.raw_data.has_key? selector.attribute
              document_value = document.raw_data[selector.attribute]
              operator = OPERATOR_MAPPING[selector.operator]
              document_value.send operator, selector_value
            end
          end

          if options[:order_by].present?
            order_attribute = options[:order_by].keys.first
            asc_or_desc = options[:order_by].values.first
            documents = documents.select do |document|
              document.raw_data.include? order_attribute
            end
            documents = documents.sort_by do |document|
              document.raw_data[order_attribute]
            end
            documents.reverse! if asc_or_desc == :desc
          end

          documents
        end

        def where(hash)
          Query.new(self).where(hash)
        end

        def order_by(field)
          Query.new(self).order_by(field)
        end

        def offset(number)
          Query.new(self).offset(number)
        end

        def limit(number)
          Query.new(self).limit(number)
        end
      end

      class Query
        def initialize(model)
          @model = model
          @where = {}
        end

        def where(constraints_hash)
          selector_hash = constraints_hash.reject { |key, value| !key.is_a? Selector }
          symbol_hash = constraints_hash.reject { |key, value| key.is_a? Selector }
          symbol_hash.each do |attribute, value|
            selector = Selector.new(:attribute => attribute, :operator => 'equal')
            selector_hash.update({ selector => value })
          end
          @where.merge! selector_hash
          self
        end

        def order_by(field)
          @order_by = field.is_a?(Symbol) ? {field => :asc} : field
          self
        end

        def offset(number)
          @offset = number
          self
        end

        def limit(number)
          @limit = number
          self
        end

        def first
          self.all.first
        end

        def last
          self.all.last
        end

        def all
          result = @model.select(:where => @where, :order_by => @order_by)
          if @offset.present?
            result = result.last([result.size - @offset, 0].max)
          end
          if @limit.present?
            result = result.first(@limit)
          end
          result
        end
      end

      class Selector
        attr_reader :attribute, :operator

        def initialize(opts = {})
          unless VALID_OPERATORS.include? opts[:operator]
            raise OperatorNotSupportedError
          end
          @attribute, @operator = opts[:attribute], opts[:operator]
        end
      end
    end
  end
end

# Add operators to symbol objects
class Symbol
  Middleman::Sitemap::Queryable::VALID_OPERATORS.each do |operator|
    class_eval <<-OPERATORS
      def #{operator}
        Middleman::Sitemap::Queryable::Selector.new(:attribute => self, :operator => '#{operator}')
      end
    OPERATORS
  end
  
  unless method_defined?(:"<=>")
    def <=>(other)
      self.to_s <=> other.to_s
    end
  end
end