#import "ViewController.h"

#import "FooUtil.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize executionOutputTextView;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setExecutionOutputTextView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc 
{
    [executionOutputTextView release];
    [super dealloc];
}

- (IBAction)executeButtonAction:(id)sender 
{
    [FooUtil setDebugBlock:^(NSString *debug) {
        // You can also just log to the console if you want
        // NSLog(@"Debug: %@", debug);
        
        if ([executionOutputTextView.text length] != 0) {
            executionOutputTextView.text = [NSString stringWithFormat:@"%@\n%@", executionOutputTextView.text, debug];
        } else {
            executionOutputTextView.text = debug;
        }
        
    }];
    
    FooUtil *fooUtil = [FooUtil sharedInstance];
    [fooUtil loadFromBundle:@"example.mrb"];
    [fooUtil execute];
    [fooUtil updateBarLocation];
    [fooUtil cleanup];
}

@end
