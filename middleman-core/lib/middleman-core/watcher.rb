# Watcher Library
require "listen"

module Middleman
  class Watcher 
    attr_reader :reload_paths, :directory, :listener

    def initialize(options = {})
      @_reload_callbacks = []
      @_change_callbacks = []
      @_delete_callbacks = []

      @reload_paths = if options[:reload_paths]
        options[:reload_paths].split(',')
      end

      @directory = options[:root] || Dir.pwd
      @changes = 0
    end
    
    def on_reload(&block)
      @_reload_callbacks << block if block_given?
      @_reload_callbacks
    end
    
    def on_change(&block)
      @_change_callbacks << block if block_given?
      @_change_callbacks
    end
    
    def on_delete(&block)
      @_delete_callbacks << block if block_given?
      @_delete_callbacks
    end
    
    def start
      return if @listener

      @listener = Listen.to(@directory, :relative_paths => true)

      @listener.change do |modified, added, removed|
        @changes += 1

        # See if the changed file is config.rb or lib/*.rb
        if needs_to_reload?(added) || needs_to_reload?(modified) || needs_to_reload?(removed)
          reload!
        else
          added.each do |path|
            on_change.each { |b| b.call(path) }
          end

          modified.each do |path|
            on_change.each { |b| b.call(path) }
          end

          removed.each do |path|
            on_delete.each { |b| b.call(path) }
          end
        end
      end
        
      # Don't block this thread
      @listener.start(false)
    end

    def wait_for_changes(goal, max_time=15)
      @changes = 0
      time_passed = 0

      yield

      loop do
        sleep(1)
        if time_passed >= max_time
          $stderr.puts "Wait for change timed out (#{time_passed}s). Goal: #{goal}. Changes: #{@changes}"
          return
        end
        return if @changes >= goal
        time_passed += 1
      end
    end
    
    def stop
      if @listener
        @listener.stop
        @listener = nil
      end
    end
    
    # Whether the passed files are config.rb, lib/*.rb or helpers
    # @param [Array<String>] paths Array of paths to check
    # @return [Boolean] Whether the server needs to reload
    def needs_to_reload?(paths)
      match_against = [
        %r{^config\.rb},
        %r{^lib/^[^\.](.*)\.rb$},
        %r{^helpers/^[^\.](.*)_helper\.rb$}
      ]
      
      if @reload_paths
        @reload_paths.split(',').each do |part|
          match_against << %r{^#{part}}
        end
      end
      
      paths.any? do |path|
        match_against.any? do |matcher|
          path.match(matcher)
        end
      end
    end
    
    def reload!
      on_reload.each { |b| b.call }
    end
  end
end