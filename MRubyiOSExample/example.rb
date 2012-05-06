#
# NB current version of mruby doesn't support attr_accessor
#
class Bar
  def initialize(name)
    @name = name
    @x = 0
    @y = 0
  end

  def name
    @name
  end

  def x
    @x
  end

  def y
    @y
  end

  def move_bar
    @x += 10
    @y += 10
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

Foo::print("Setting variable to nil")
f = nil

Foo::print("Done")
