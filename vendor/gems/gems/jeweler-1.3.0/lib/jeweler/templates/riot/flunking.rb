require 'teststrap'

context "<%= require_name %>" do
  setup do
    false
  end

  asserts "i'm a failure :(" do
    topic
  end
end
