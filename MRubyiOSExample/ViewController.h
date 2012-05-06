#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (retain, nonatomic) IBOutlet UITextView *executionOutputTextView;

- (IBAction)executeButtonAction:(id)sender;

@end
