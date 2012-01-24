class Hello < Thor
  desc "hello", "Say hello"
  def hello
    puts "Hello World"
  end
end