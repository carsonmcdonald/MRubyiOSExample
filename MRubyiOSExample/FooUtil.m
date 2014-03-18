#import "FooUtil.h"
#import "FooData.h"

static DebugBlock debugBlock;

static void foo_data_free(mrb_state *mrb, void *obj)
{
    debugBlock(@"FooData free called");
    
    FooData *fooData = (FooData *)obj;
    [fooData release];
}

static const struct mrb_data_type foo_data_type = {
    "fooData", foo_data_free,
};

static mrb_value foo_class_init(mrb_state *mrb, mrb_value obj)
{
    debugBlock(@"FooData init");
    
    FooData *fooData = [[FooData alloc] init];
    
    mrb_iv_set(mrb, obj, mrb_intern_cstr(mrb, "fooData"), mrb_obj_value(Data_Wrap_Struct(mrb, mrb->object_class, &foo_data_type, (void*) fooData)));
    
    return obj;
}

static mrb_value foo_class_increment(mrb_state *mrb, mrb_value obj)
{
    FooData *fooData = nil;
    
    mrb_value value_fooData = mrb_iv_get(mrb, obj, mrb_intern_cstr(mrb, "fooData"));
    fooData = DATA_GET_PTR(mrb, value_fooData, &foo_data_type, FooData);
    if (!fooData) {
        mrb_raise(mrb, E_ARGUMENT_ERROR, "Internal state corrupted");
    }    
    
    [fooData increment];
    
    return mrb_nil_value();
}

static mrb_value foo_class_get_count(mrb_state *mrb, mrb_value obj)
{
    FooData *fooData = nil;
    
    mrb_value value_fooData = mrb_iv_get(mrb, obj, mrb_intern_cstr(mrb, "fooData"));
    fooData = DATA_GET_PTR(mrb, value_fooData, &foo_data_type, FooData);
    if (!fooData) {
        mrb_raise(mrb, E_ARGUMENT_ERROR, "Internal state corrupted");
    }    
    
    mrb_value count_value;
    count_value.tt = MRB_TT_FIXNUM;
    count_value.value.i = fooData.count;
    
    return mrb_Integer(mrb, count_value);
}

// Simple class method call
static mrb_value foo_simple(mrb_state *mrb, mrb_value obj)
{
    debugBlock(@"Foo::simple called");
    
    return mrb_nil_value();
}

// Message printing class method call
static mrb_value foo_print_message(mrb_state* mrb, mrb_value obj)
{    
    char *message = NULL;
    mrb_get_args(mrb, "z", &message);
    
    debugBlock([NSString stringWithFormat:@"Foo::printMessage => %s", message]);
    
    return mrb_nil_value();
}

static mrb_value bar_execute_with(mrb_state *mrb, mrb_value obj)
{
    mrb_int x, y;
    mrb_get_args(mrb, "ii", &x, &y);
    
    debugBlock([NSString stringWithFormat:@"Values from within block: x=%d, y=%d", x, y]);
    
    mrb_value count_value;
    count_value.tt = MRB_TT_FIXNUM;
    count_value.value.i = x + y;
    
    return mrb_Integer(mrb, count_value);
}

@implementation FooUtil

- (id)init
{
    self = [super init];
    if (self) 
    {
        // Setup the mruby environment, define local modules/classes
        mrb = mrb_open();
        
        foo_module = mrb_define_module(mrb, "Foo");
        
        // Define a class method not no args
        mrb_define_class_method(mrb, foo_module, "simple", foo_simple, MRB_ARGS_NONE());
        mrb_define_class_method(mrb, foo_module, "print", foo_print_message, MRB_ARGS_REQ(1));
        
        // Define a class and a few methods
        foo_class = mrb_define_class_under(mrb, foo_module, "FooData", mrb->object_class);
        
        mrb_define_method(mrb, foo_class, "initialize", foo_class_init, MRB_ARGS_NONE());
        mrb_define_method(mrb, foo_class, "increment", foo_class_increment, MRB_ARGS_NONE());
        mrb_define_method(mrb, foo_class, "count", foo_class_get_count, MRB_ARGS_NONE());
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

+ (FooUtil *)sharedInstance
{   
    static FooUtil *sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[FooUtil alloc] init];
    });
    
    return sharedInstance;
}

+ (void)setDebugBlock:(DebugBlock) aDebugBlock
{
    debugBlock = aDebugBlock;
}

- (bool)loadFromBundle: (NSString *)filename
{
    NSString *bundleLocation = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
    
    if(!bundleLocation)
    {
        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@ not found in bundle.", filename] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorView show];
        
        return NO;
    }
    
    FILE *fp = fopen([bundleLocation UTF8String], "rb");
    if (fp == NULL)
    {
        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error loading bundled mrb file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorView show];
        
        return NO;
    }
    else
    {
        irep = mrb_read_irep_file(mrb, fp);
        fclose(fp);
        if(irep == NULL)
        {
            UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error reading bundled mrb irep." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorView show];
            
            return NO;
        }
    }
    
    return YES;
}

- (void)execute
{
    mrb_value return_value = mrb_run(mrb, mrb_proc_new(mrb, irep), mrb_top_self(mrb));
    
    if(!mrb_eql(mrb, return_value, mrb_nil_value()))
    {
        struct RString *str = mrb_str_ptr(mrb_funcall(mrb, return_value, "inspect", 0));

        debugBlock([NSString stringWithFormat:@"Return value: %s", str->ptr]);
    }
    
    // Set up an example instance of the Bar class from the script that was just run
    mrb_value argv[1];
    
    // Example of setting an input value using an NSString
    argv[0] = mrb_str_new_cstr(mrb, [@"Bar1" UTF8String]);
    
    barInstance = mrb_class_new_instance(mrb, 1, argv, mrb_class_get(mrb, "Bar"));
}

- (void)cleanup
{
    mrb_garbage_collect(mrb);
}

- (void)updateBarLocation
{
    mrb_value bar_name = mrb_funcall_argv(mrb, barInstance, mrb_intern_cstr(mrb, "name"), 0, NULL);
    mrb_value bar_x = mrb_funcall_argv(mrb, barInstance, mrb_intern_cstr(mrb, "x"), 0, NULL);
    mrb_value bar_y = mrb_funcall_argv(mrb, barInstance, mrb_intern_cstr(mrb, "y"), 0, NULL);
    
    debugBlock([NSString stringWithFormat:@"Bar update location before => %s, %d, %d", mrb_str_ptr(bar_name)->ptr, bar_x.value.i, bar_x.value.i]);
    
    mrb_funcall_argv(mrb, barInstance, mrb_intern_cstr(mrb, "move_bar"), 0, NULL);
    
    bar_x = mrb_funcall_argv(mrb, barInstance, mrb_intern_cstr(mrb, "x"), 0, NULL);
    bar_y = mrb_funcall_argv(mrb, barInstance, mrb_intern_cstr(mrb, "y"), 0, NULL);
    
    debugBlock([NSString stringWithFormat:@"Bar update location after => %s, %d, %d", mrb_str_ptr(bar_name)->ptr, bar_x.value.i, bar_x.value.i]);
}

- (void)blockExample
{
    struct RProc *b = mrb_proc_new_cfunc(mrb, bar_execute_with);
    mrb_value proc = mrb_obj_value(b);
    
    mrb_value r_val_proc = mrb_funcall_argv(mrb, barInstance, mrb_intern_cstr(mrb, "execute_with_proc"), 1, &proc);
    debugBlock([NSString stringWithFormat:@"Return from proc => %d", r_val_proc.value.i]);
    
    mrb_value r_val_yield = mrb_funcall_with_block(mrb, barInstance, mrb_intern_cstr(mrb, "execute_with_yield"), 0, NULL, proc);
    debugBlock([NSString stringWithFormat:@"Return from yield => %d", r_val_yield.value.i]);
}

@end
