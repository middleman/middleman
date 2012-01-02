require 'rb-inotify/native'
require 'rb-inotify/native/flags'
require 'rb-inotify/notifier'
require 'rb-inotify/watcher'
require 'rb-inotify/event'

# The root module of the library, which is laid out as so:
#
# * {Notifier} -- The main class, where the notifications are set up
# * {Watcher} -- A watcher for a single file or directory
# * {Event} -- An filesystem event notification
module INotify
  # An array containing the version number of rb-inotify.
  # The numbers in the array are the major, minor, and patch versions,
  # respectively.
  VERSION = [0, 8, 8]
end
