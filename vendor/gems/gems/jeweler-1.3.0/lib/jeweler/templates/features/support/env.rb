$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require '<%= require_name %>'

require '<%= feature_support_require %>'
<% if feature_support_extend %>

World(<%= feature_support_extend %>)
<% end %>
