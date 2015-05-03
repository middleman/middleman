# require 'spec_helper'
require 'middleman-core/callback_manager'

describe ::Middleman::CallbackManager do
  it "adds a simple key" do
    counters = {
      test1: 0,
      test2: 0,
      test3: 0
    }

    m = ::Middleman::CallbackManager.new
    m.add(:test3) { counters[:test3] += 1 }
    m.add(:test1) { counters[:test1] += 1 }
    m.add(:test2) { counters[:test2] += 1 }
    m.add(:test1) { counters[:test1] += 1 }
    m.add(:test2) { counters[:test2] += 1 }
    m.add(:test1) { counters[:test1] += 1 }
    m.add(:test3) { counters[:test3] += 1 }

    m.execute(:test1)
    m.execute(:test2)

    expect(counters[:test1]).to eq 3
    expect(counters[:test2]).to eq 2
    expect(counters[:test3]).to eq 0
  end

  it "callbacks run in order" do
    result = []

    m = ::Middleman::CallbackManager.new
    m.add(:test) { result.push(1) }
    m.add(:test) { result.push(2) }
    m.add(:test) { result.push(3) }

    m.execute(:test)

    expect(result.join('')).to eq '123'
  end

  it "adds a nested key" do
    counters = {
      test1: 0,
      test1a: 0
    }

    m = ::Middleman::CallbackManager.new
    m.add([:test1, :a]) { |n| counters[:test1a] += n }
    m.add(:test1) { counters[:test1] += 1 }

    m.execute([:test1, :a], [2])
    m.execute([:test1, :b], [5])

    expect(counters[:test1]).to eq 0
    expect(counters[:test1a]).to eq 2
  end

  it "works in isolation" do
    m1 = ::Middleman::CallbackManager.new
    m2 = ::Middleman::CallbackManager.new

    counters = {
      test1: 0,
      test2: 0
    }

    m1.add(:test1) { |n| counters[:test1] += n }
    m2.add(:test1) { |n| counters[:test2] += n }

    m1.execute(:test1, [2])
    m2.execute(:test1, [5])
    m1.execute(:test2, [20])
    m2.execute(:test2, [50])

    expect(counters[:test1]).to eq 2
    expect(counters[:test2]).to eq 5
  end

  it "installs to arbitrary instances" do
    instance = Class.new(Object).new

    m = ::Middleman::CallbackManager.new
    m.install_methods!(instance, [:ready])

    counter = 0
    instance.ready { |n| counter += n }
    instance.execute_callbacks(:ready, [2])
    instance.execute_callbacks(:ready2, [10])
    instance.execute_callbacks([:ready], [20])
    instance.execute_callbacks([:ready, :two], [20])
    expect(counter).to eq 2
  end

  it "executes in default scope" do
    instance = Class.new(Object).new
    m = ::Middleman::CallbackManager.new
    m.install_methods!(instance, [:ready])

    internal_self = nil
    instance.ready do
      internal_self = self
    end

    instance.execute_callbacks(:ready)

    expect(internal_self) === instance
  end

  it "executes in custom scope" do
    instance = Class.new(Object).new
    m = ::Middleman::CallbackManager.new
    m.install_methods!(instance, [:ready])

    external_class = Struct.new(:counter, :scope) do
      def when_ready(n)
        self[:scope] = self
        self[:counter] += n
      end
    end

    external_instance = external_class.new(0, nil)

    instance.ready(&external_instance.method(:when_ready))

    instance.execute_callbacks(:ready, [5])
    
    expect(external_instance[:scope]).to eq external_instance
    expect(external_instance[:counter]).to eq 5
  end

end