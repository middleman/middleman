activate :directory_indexes
page "/leave_me_alone.html", directory_index: false

page "/wildcard*", directory_index: false
page /regex_.*/, directory_index: false
