module Compass
  module Configuration
    # The inheritance module makes it easy for configuration data to inherit from
    # other instances of configuration data. This makes it easier for external code to layer
    # bits of configuration from various sources.
    module Inheritance

      def self.included(base)
        # inherited_data stores configuration data that this configuration object will
        # inherit if not provided explicitly.
        base.send :attr_accessor, :inherited_data, :set_attributes, :top_level

        base.send(:include, InstanceMethods)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def inherited_writer(*attributes)
          attributes.each do |attribute|
            line = __LINE__ + 1
            class_eval %Q{
              def #{attribute}=(value)                        # def css_dir=(value)
                @set_attributes ||= {}                        #   @set_attributes ||= {}
                @set_attributes[#{attribute.inspect}] = true  #   @set_attributes[:css_dir] = true
                @#{attribute} = value                         #   @css_dir = value
              end                                             # end

              def unset_#{attribute}!                         # def unset_css_dir!
                unset!(#{attribute.inspect})                  #   unset!(:css_dir)
              end                                             # end

              def #{attribute}_set?                           # def css_dir_set?
                set?(#{attribute.inspect})                    #   set?(:css_dir)
              end                                             # end
            }, __FILE__, line
          end
        end

        # Defines the default reader to be an inherited_reader that will look at the inherited_data for its
        # value when not set. The inherited reader calls to a raw reader that acts like a normal attribute
        # reader but prefixes the attribute name with "raw_".
        def inherited_reader(*attributes)
          attributes.each do |attribute|
            line = __LINE__ + 1
            class_eval %Q{
              def raw_#{attribute}                         # def raw_css_dir
                @#{attribute}                              #   @css_dir
              end                                          # end
              def #{attribute}_without_default             # def css_dir_without_default
                read_without_default(#{attribute.inspect}) #  read_without_default(:css_dir)
              end                                          # end
              def #{attribute}                             # def css_dir
                read(#{attribute.inspect})                 #  read(:css_dir)
              end                                          # end
            }, __FILE__, line
          end
        end

        def inherited_accessor(*attributes)
          inherited_reader(*attributes)
          inherited_writer(*attributes)
        end

        
      end

      module InstanceMethods

        def on_top!
          self.set_top_level(self)
        end

        def set_top_level(new_top)
          self.top_level = new_top
          if self.inherited_data.respond_to?(:set_top_level)
            self.inherited_data.set_top_level(new_top)
          end
        end


        def inherit_from!(data)
          if self.inherited_data
            self.inherited_data.inherit_from!(data)
          else
            self.inherited_data = data
          end
          self
        end

        def unset!(attribute)
          @set_attributes ||= {}
          send("#{attribute}=", nil)
          @set_attributes.delete(attribute)
          nil
        end

        def set?(attribute)
          @set_attributes ||= {}
          @set_attributes[attribute]
        end

        def default_for(attribute)
          method = "default_#{attribute}".to_sym
          if respond_to?(method)
            send(method)
          end
        end

        # Read an explicitly set value that is either inherited or set on this instance
        def read_without_default(attribute)
          if set?(attribute)
            send("raw_#{attribute}")
          elsif inherited_data.respond_to?("#{attribute}_without_default")
            inherited_data.send("#{attribute}_without_default")
          elsif inherited_data.respond_to?(attribute)
            inherited_data.send(attribute)
          end
        end

        # Read a value that is either inherited or set on this instance, if we get to the bottom-most configuration instance,
        # we ask for the default starting at the top level.
        def read(attribute)
          if !(v = send("#{attribute}_without_default")).nil?
            v
          else
            top_level.default_for(attribute)
          end
        end

        def method_missing(meth)
          if inherited_data
            inherited_data.send(meth)
          else
            raise NoMethodError, meth.to_s
          end
        end

        def respond_to?(meth)
          if super
            true
          elsif inherited_data
            inherited_data.respond_to?(meth)
          else
            false
          end
        end

        def debug
          instances = [self]
          instances << instances.last.inherited_data while instances.last.inherited_data
          normalized_attrs = {}
          ATTRIBUTES.each do |prop|
            values = []
            instances.each do |instance|
              values << {
                :raw => (instance.send("raw_#{prop}") rescue nil),
                :value => (instance.send("#{prop}_without_default") rescue nil),
                :default => (instance.send("default_#{prop}") rescue nil),
                :resolved => instance.send(prop)
              }
            end
            normalized_attrs[prop] = values
          end
          normalized_attrs
        end

      end
    end
  end
end
