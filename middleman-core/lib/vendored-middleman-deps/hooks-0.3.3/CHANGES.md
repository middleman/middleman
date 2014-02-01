## 0.3.3

* Fix a bug where the hook writer method (e.g. `#after_dark`) wasn't available on the instance even when `InstanceHooks` was included.

## 0.3.2

* Added `Hooks::InstanceHooks` to add hooks and/or callbacks on instance level. Thanks to @mpapis for that suggestion.

## 0.3.1

* Fix a bug, string hook names are now treated as symbols.

## 0.3.0

* The callback chain can now be halted by configuring the hook as `halts_on_falsey: true` and returning `nil` or `false` from the callback.
* Internal refactorings: hooks are now encapsulated in `Hook` instances and run their callback chains.

## 0.2.2

* `#run_hook` now returns the list of callback results.

## 0.2.1

* You can now pass multiple hook names to `#define_hooks`.

## 0.2.0

h3. Changes
* Callback blocks are now executed on the instance using `instance_exec`. If you need to access the class (former context) use `self.class`.

## 0.1.4

* An uninitialized `inheritable_attr` doesn't crash since it is not cloned anymore. Note that an uncloneable attribute value still causes an exception.
