class Bar
  attr_reader :name, :x, :y
    
  def initialize(name)
    @name = name
    @x = 0
    @y = 0
  end

  def move_bar
    @x += 10
    @y += 10
  end
    
  def execute_with_proc(p)
    p.call(@x, @y)
  end
    
  def execute_with_yield(&b)
    yield @x, @y
  end

end

class FiberOne
    def initialize(foo)
        @foo = foo
        @foo_fiber = Fiber.new {
            @foo.increment()
            Fiber.yield @foo.count
            @foo.increment()
            Fiber.yield @foo.count
        }
    end
    
    def go
        @foo_fiber.resume()
    end
end

Foo::print("Calling Foo::simple()")
Foo::simple()

Foo::print("Calling Foo::FooData.new()")
f = Foo::FooData.new()

Foo::print("Calling Foo::FooData.increment()")
f.increment()

Foo::print("Count is currently: #{f.count}")
f.increment()
Foo::print("Count is currently: #{f.count}")

f_one = FiberOne.new(f)
Foo::print("Count is (Fiber): #{f_one.go()}")
Foo::print("Count is (Fiber): #{f_one.go()}")

Foo::print("Setting variable to nil")
f = nil

Foo::print("Done")
