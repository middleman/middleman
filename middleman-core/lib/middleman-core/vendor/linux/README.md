# rb-inotify

This is a simple wrapper over the [inotify](http://en.wikipedia.org/wiki/Inotify) Linux kernel subsystem
for monitoring changes to files and directories.
It uses the [FFI](http://wiki.github.com/ffi/ffi) gem to avoid having to compile a C extension.

[API documentation is available on rdoc.info](http://rdoc.info/projects/nex3/rb-inotify).

## Basic Usage

The API is similar to the inotify C API, but with a more Rubyish feel.
First, create a notifier:

    notifier = INotify::Notifier.new

Then, tell it to watch the paths you're interested in
for the events you care about:

    notifier.watch("path/to/foo.txt", :modify) {puts "foo.txt was modified!"}
    notifier.watch("path/to/bar", :moved_to, :create) do |event|
      puts "#{event.name} is now in path/to/bar!"
    end

Inotify can watch directories or individual files.
It can pay attention to all sorts of events;
for a full list, see [the inotify man page](http://www.tin.org/bin/man.cgi?section=7&topic=inotify).

Finally, you get at the events themselves:

    notifier.run

This will loop infinitely, calling the appropriate callbacks when the files are changed.
If you don't want infinite looping,
you can also block until there are available events,
process them all at once,
and then continue on your merry way:

    notifier.process

## Advanced Usage

Sometimes it's necessary to have finer control over the underlying IO operations
than is provided by the simple callback API.
The trick to this is that the \{INotify::Notifier#to_io Notifier#to_io} method
returns a fully-functional IO object,
with a file descriptor and everything.
This means, for example, that it can be passed to `IO#select`:

     # Wait 10 seconds for an event then give up
     if IO.select([notifier.to_io], [], [], 10)
       notifier.process
     end

It can even be used with EventMachine:

     require 'eventmachine'

     EM.run do
       EM.watch notifier.to_io do
         notifier.process
       end
     end

Unfortunately, this currently doesn't work under JRuby.
JRuby currently doesn't use native file descriptors for the IO object,
so we can't use the notifier's file descriptor as a stand-in.
