#import "FooData.h"

@implementation FooData

@synthesize count;

- (id)init
{
    self = [super init];
    if (self) 
    {
        count = 0;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)increment
{
    count++;
}

@end
