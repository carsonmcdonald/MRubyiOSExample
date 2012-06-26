#import <UIKit/UIKit.h>

#include "mruby/mruby.h"
#include "mruby/mruby/proc.h"
#include "mruby/mruby/dump.h"
#include "mruby/mruby/class.h"
#include "mruby/mruby/variable.h"
#include "mruby/mruby/data.h"
#include "mruby/mruby/array.h"
#include "mruby/mruby/string.h"

typedef void (^ DebugBlock)(NSString *);

@interface FooUtil : NSObject
{
    @private
    mrb_state *mrb;
    struct RClass* foo_module;
    struct RClass* foo_class;
    int irep_number;
    mrb_value barInstance;
}

+ (FooUtil *)sharedInstance;
+ (void)setDebugBlock:(DebugBlock) aDebugBlock;

- (void)loadFromBundle: (NSString *)filename;
- (void)execute;
- (void)cleanup;
- (void)updateBarLocation;

@end
