Feature: Middleman CLI

  Scenario: Create a new project
    Given I run `middleman init MY_PROJECT`
    Then the exit status should be 0
    When I cd to "MY_PROJECT"
    Then the following files should exist:
      | config.rb                                     |
      | source/index.html.erb                         |
      | source/images/background.png                  |
      | source/images/middleman.png                   |
      | source/layouts/layout.erb                     |
      | source/javascripts/all.js                     |
      | source/stylesheets/all.css                    |
      | source/stylesheets/normalize.css              |
      
  Scenario: Create a new project (alias i)
    When I run `middleman i MY_PROJECT`
    Then a directory named "MY_PROJECT" should exist
    
  Scenario: Create a new project (alias i)
    When I run `middleman new MY_PROJECT`
    Then a directory named "MY_PROJECT" should exist
  
  Scenario: Create a new project (alias i)
    When I run `middleman n MY_PROJECT`
    Then a directory named "MY_PROJECT" should exist
    
  Scenario: Create a new project with Rack
    When I run `middleman init MY_PROJECT --rack`
    Then a directory named "MY_PROJECT" should exist
    When I cd to "MY_PROJECT"
    Then the following files should exist:
      | config.rb                                     |
      | config.ru                                     |
    Then the following files should not exist:
      | Gemfile                                       |
    
  Scenario: Create a new project with Bundler
    When I run `middleman init MY_PROJECT --bundler`
    Then a directory named "MY_PROJECT" should exist
    When I cd to "MY_PROJECT"
    Then the following files should exist:
      | config.rb                                     |
      | Gemfile                                       |
    Then the following files should not exist:  
      | config.ru                                     |
      
  Scenario: Create a new HTML5 project
    When I run `middleman init MY_PROJECT --template=html5`
    Then a directory named "MY_PROJECT" should exist
    When I cd to "MY_PROJECT"
    Then the following files should exist:
      | config.rb                                     |
    Then the following files should not exist:
      | config.ru                                     |
      | Gemfile                                       |
    And the file "config.rb" should contain "set :js_dir, 'js'"
    Then a directory named "source" should exist
    When I cd to "source"
    Then the following files should exist:
      | index.html                                    |
      | humans.txt                                    |
      | js/script.js                                  |
      
  Scenario: Create a new HTML5 project with Rack
    When I run `middleman init MY_PROJECT --rack --template=html5`
    Then a directory named "MY_PROJECT" should exist
    When I cd to "MY_PROJECT"
    Then the following files should exist:
      | config.rb                                     |
      | config.ru                                     |
    Then the following files should not exist:
      | Gemfile                                       |
    
  Scenario: Create a new HTML5 project with Bundler
    When I run `middleman init MY_PROJECT --bundler --template=html5`
    Then a directory named "MY_PROJECT" should exist
    When I cd to "MY_PROJECT"
    Then the following files should exist:
      | config.rb                                     |
      | Gemfile                                       |
    Then the following files should not exist:  
      | config.ru                                     |
      
  Scenario: Create a new Mobile HTML5 project
    When I run `middleman init MY_PROJECT --template=mobile`
    Then a directory named "MY_PROJECT" should exist
    When I cd to "MY_PROJECT"
    Then the following files should exist:
      | config.rb                                     |
    Then the following files should not exist:
      | config.ru                                     |
      | Gemfile                                       |
    Then a directory named "source" should exist
    When I cd to "source"
    Then the following files should exist:
      | index.html                                    |
      | humans.txt                                    |
      | js/libs/respond.min.js                        |
      
  Scenario: Create a new Mobile HTML5 project with Rack
    When I run `middleman init MY_PROJECT --rack --template=mobile`
    Then a directory named "MY_PROJECT" should exist
    When I cd to "MY_PROJECT"
    Then the following files should exist:
      | config.rb                                     |
      | config.ru                                     |
    Then the following files should not exist:
      | Gemfile                                       |
    
  Scenario: Create a new Mobile HTML5 project with Bundler
    When I run `middleman init MY_PROJECT --bundler --template=mobile`
    Then a directory named "MY_PROJECT" should exist
    When I cd to "MY_PROJECT"
    Then the following files should exist:
      | config.rb                                     |
      | Gemfile                                       |
    Then the following files should not exist:  
      | config.ru                                     |