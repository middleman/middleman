# Hooks

_Generic hooks with callbacks for Ruby._


## Introduction

_Hooks_ lets you define hooks declaratively in your ruby class. You can add callbacks to your hook, which will be run as soon as _you_ run the hook!

It's almost like ActiveSupport::Callbacks but 76,6% less complex. Instead, it is not more than a few lines of code, one method compilation, no `method_missing` and no magic.

Also, you may pass additional arguments to your callbacks when invoking a hook.

## Example

Let's take... a cat.

```ruby
require 'hooks'

class Cat
  include Hooks

  define_hooks :before_dinner, :after_dinner
```

Now you can add callbacks to your hook declaratively in your class.

```ruby
  before_dinner :wash_paws

  after_dinner do
    puts "Ice cream for #{self}!"
  end

  after_dinner :have_a_desert   # => refers to Cat#have_a_desert

  def have_a_desert
    puts "Hell, yeah!"
  end
```

This will run the block and `#have_a_desert` from above.

```ruby
cat.run_hook :after_dinner
# => Ice cream for #<Cat:0x8df9d84>!
     Hell, yeah!
```

Callback blocks and methods will be executed with instance context. Note how `self` in the block refers to the Cat instance.


## Inheritance

Hooks are inherited, here's a complete example to put it all together.

```ruby
class Garfield < Cat

  after_dinner :want_some_more

  def want_some_more
    puts "Is that all?"
  end
end


Garfield.new.run_hook :after_dinner
# => Ice cream for #<Cat:0x8df9d84>!
     Hell, yeah!
     Is that all?
```

Note how the callbacks are invoked in the order they were inherited.


## Options for Callbacks

You're free to pass any number of arguments to #run_callback, those will be passed to the callbacks.

```ruby
cat.run_hook :before_dinner, cat, Time.now
```

The callbacks should be ready for receiving parameters.

```ruby
before_dinner :wash_pawns
before_dinner do |who, when|
  ...
end

def wash_pawns(who, when)
```

Not sure why a cat should have ice cream for dinner. Beside that, I was tempted naming this gem _hooker_.


## Running And Halting Hooks

Using `#run_hook` doesn't only run all callbacks for this hook but also returns an array of the results from each callback method or block.

```ruby
class Garfield
  include Hooks
  define_hook :after_dark

  after_dark { "Chase mice" }
  after_dark { "Enjoy supper" }
end

Garfield.new.run_hook :after_dark
# => ["Chase mice", "Enjoy supper"]
```

This is handy if you need to collect data from your callbacks without having to access a global (brrr) variable.

With the `:halts_on_falsey` option you can halt the callback chain when a callback returns `nil` or `false`.

```ruby
class Garfield
  include Hooks
  define_hook :after_dark, halts_on_falsey: true

  after_dark { "Chase mice" }
  after_dark { nil }
  after_dark { "Enjoy supper" }
end

result = Garfield.new.run_hook :after_dark
# => ["Chase mice"]
```

This will only run the first two callbacks. Note that the result doesn't contain the `nil` value. You even can check if the chain was halted.

```ruby
result.halted? #=> true
```

## Instance Hooks

You can also define hooks and/or add callbacks per instance. This is helpful if your class should define a basic set of hooks and callbacks that are then extended by instances.

```ruby
class Cat
  include Hooks
  include Hooks::InstanceHooks

  define_hook :after_dark

  after_dark { "Chase mice" }
end
```

Note that you have to include `Hooks::InstanceHooks` to get this additional functionality.

See how callbacks can be added to a separate object, now.

```ruby
garfield = Cat.new

garfield.after_dark :sleep
garfield.run_hook(:after_dark) # => invoke "Chase mice" hook and #sleep
```

This will copy all callbacks from the `after_dark` hook to the instance and add a second hook. This all happens on the `garfield` instance, only, and leaves the class untouched.

Naturally, adding new hooks works like-wise.

```ruby
garfield.define_hook :before_six
garfield.before_six { .. }
```
This feature was added in 0.3.2.


## Installation

In your Gemfile, do

```ruby
gem "hooks"
```

## Anybody using it?

* Hooks is already used in [Apotomo](http://github.com/apotonick/apotomo), a hot widget framework for Rails.
* The [datamappify](https://github.com/fredwu/datamappify) gem uses hooks and the author Fred Wu contributed to this gem!

## Similar libraries

* http://github.com/nakajima/aspectory
* http://github.com/auser/backcall
* http://github.com/mmcgrana/simple_callbacks


## License

Copyright (c) 2013, Nick Sutterer

Released under the MIT License.
