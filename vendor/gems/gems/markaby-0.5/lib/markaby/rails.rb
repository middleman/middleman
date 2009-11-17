module Markaby

  # Markaby helpers for Rails.
  module ActionControllerHelpers
    # Returns a string of HTML built from the attached +block+.  Any +options+ are
    # passed into the render method.
    #
    # Use this method in your controllers to output Markaby directly from inside.
    def render_markaby(options = {}, &block)
      render options.merge({ :text => Builder.new({}, self, &block).to_s })
    end
  end

  class ActionViewTemplateHandler
    def initialize(action_view)
      @action_view = action_view
    end
    def render(template, local_assigns = {})
      Template.new(template).render(@action_view.assigns.merge(local_assigns), @action_view)
    end
  end

  class Builder
    # Emulate ERB to satisfy helpers like <tt>form_for</tt>.
    def _erbout; self end

    # Content_for will store the given block in an instance variable for later use 
    # in another template or in the layout.
    #
    # The name of the instance variable is content_for_<name> to stay consistent 
    # with @content_for_layout which is used by ActionView's layouts.
    #
    # Example:
    #
    #   content_for("header") do
    #     h1 "Half Shark and Half Lion"
    #   end
    #
    # If used several times, the variable will contain all the parts concatenated.
    def content_for(name, &block)
      @helpers.assigns["content_for_#{name}"] =
        eval("@content_for_#{name} = (@content_for_#{name} || '') + capture(&block)")
    end
  end

end
