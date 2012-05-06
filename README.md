## About

This is a complete example of using [mruby](https://github.com/mruby/mruby) 
embedded in an iOS app. You should be able to clone this repo and open it using 
XCode 4 then build and run. It has examples of calling Ruby code from 
Objective-C and Objective-C code from Ruby.

## Notes/Details

This example includes a framework called MRuby.framework that was created
using the build script found in the [ios ruby embedded](https://github.com/carsonmcdonald/ios-ruby-embedded)
repo. To modify the Ruby included in this example you will need to have the
mruby compiler that can be obtained by building the ios-ruby-embedded project
or by building the mruby project.

Files of note:

* example.rb - This is the Ruby code for the example and has to be compiled
  into example.mrb before changes will take place.
* example.mrb - This is the compiled version of example.rb.
* FooData.h/m - This is an example data class that is wrapped using a Ruby
  class named FooData.
* FooUtil.h/m - This is where all the interaction with mruby happens. It
  coordinates different parts of the examples as well.

## License

MIT to match the mruby license. See the LICENSE file for full license.
