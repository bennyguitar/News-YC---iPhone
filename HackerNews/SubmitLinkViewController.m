//
//  SubmitLinkViewController.m
//  HackerNews
//
//  Created by Benjamin Gordon on 5/11/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "SubmitLinkViewController.h"

@interface SubmitLinkViewController () {
    __weak IBOutlet UITextField *titleTextField;
    __weak IBOutlet UITextField *linkTextField;
    __weak IBOutlet UITextView *textTextView;
}

@property (weak, nonatomic) IBOutlet UIButton *submitStoryButton;
- (IBAction)didClickSubmitStory:(id)sender;

@end

@implementation SubmitLinkViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self buildUI];
    
    // Set Up NotificationCenter
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard) name:@"HideKeyboard" object:nil];
}

#pragma mark - Memory
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI
-(void)buildUI {
    self.submitStoryButton.layer.cornerRadius = 10;
    [Helpers makeShadowForView:self.submitStoryButton withRadius:10];
}

#pragma mark - TextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    return YES;
}

-(void)hideKeyboard {
    [titleTextField resignFirstResponder];
    [linkTextField resignFirstResponder];
    [textTextView resignFirstResponder];
}

#pragma mark - Submit
- (IBAction)didClickSubmitStory:(id)sender {
    [[HNManager sharedManager] submitPostWithTitle:titleTextField.text link:linkTextField.text text:textTextView.text completion:^(BOOL success) {
        if (success) {
            [KGStatusBar showSuccessWithStatus:@"Submit Success"];
        }
        else {
            [KGStatusBar showErrorWithStatus:@"Submit Failed. Please try again."];
        }
    }];
}
@end
