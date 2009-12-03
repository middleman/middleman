module Sass
  module Tree
    class Node
      unless method_defined?(:visit_depth_first)
        def visit_depth_first(visitor)
          visitor.visit(self)
          visitor.down(self) if children.any? and visitor.respond_to?(:down)
          if is_a?(ImportNode) && visitor.import?(self)
            root = Sass::Files.tree_for(import, @options)
            imported_children = root.children
          end

          (imported_children || children).each do |child|
            break if visitor.respond_to?(:stop?) && visitor.stop?
            child.visit_depth_first(visitor)
          end
          visitor.up(self) if children.any?
        end
      end
    end
  end
end

