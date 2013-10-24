//
//  SubmitHNViewController.m
//  HackerNews
//
//  Created by Ben Gordon on 10/22/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "Helpers.h"
#import "SubmitHNViewController.h"
#import "libHN.h"
#import "HNSingleton.h"
#import "FailedLoadingView.h"
#import "KGStatusBar.h"

@interface SubmitHNViewController ()

@property (nonatomic, assign) id HNObject;
@property (nonatomic, assign) SubmitHNType SubmitType;

// Submission
@property (strong, nonatomic) IBOutlet UIView *SubmitView;
@property (weak, nonatomic) IBOutlet UITextField *SubmitTitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *SubmitLinkTextField;
@property (weak, nonatomic) IBOutlet UITextView *SubmitSelfTextView;
@property (weak, nonatomic) IBOutlet UILabel *SubmitHeaderLabel;
@property (weak, nonatomic) IBOutlet UIButton *SubmitDoneEditingButton;
@property (weak, nonatomic) IBOutlet UIButton *SubmitButton;

// Comment
@property (weak, nonatomic) IBOutlet UITextView *CommentTextView;
@property (strong, nonatomic) IBOutlet UIView *CommentView;
@property (weak, nonatomic) IBOutlet UIButton *CommentSubmitButton;
@property (weak, nonatomic) IBOutlet UIButton *CommentDoneEditing;



@end

@implementation SubmitHNViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil type:(SubmitHNType)type hnObject:(id)hnObject
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.SubmitType = type;
        self.HNObject = hnObject;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Register for Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard) name:@"HideKeyboard" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheme) name:@"DidChangeTheme" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    // Build Nav
    [Helpers buildNavigationController:self leftImage:NO rightImages:@[@"Submit"] rightActions:@[@"didPressSubmit"]];
    
    // Color UI
    [self colorUI];
    
    // Place Correct View in
    if (self.SubmitType == SubmitHNTypePost) {
        [self.view addSubview:self.SubmitView];
    }
    else {
        [self.view addSubview:self.CommentView];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [[HNManager sharedManager] cancelAllRequests];
}


#pragma mark - UI
- (void)colorUI {
    self.view.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"CellBG"];
    self.SubmitView.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"CellBG"];
    self.SubmitLinkTextField.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"BottomBar"];
    self.SubmitTitleTextField.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"BottomBar"];
    self.SubmitSelfTextView.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"BottomBar"];
    self.SubmitTitleTextField.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"MainFont"];
    self.SubmitLinkTextField.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"MainFont"];
    self.SubmitSelfTextView.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"MainFont"];
    self.CommentTextView.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"MainFont"];
    self.CommentView.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"CellBG"];
    self.CommentTextView.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"BottomBar"];
}

- (void)changeTheme {
    self.SubmitView.alpha = 0;
    self.CommentView.alpha = 0;
    [self colorUI];
    [UIView animateWithDuration:0.2 animations:^{
        self.SubmitView.alpha = 1;
        self.CommentView.alpha = 1;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - TextView Delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (textView == self.SubmitSelfTextView) {
        [self animateSubmitViewUp:YES];
    }
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (textView == self.SubmitSelfTextView) {
        [self animateSubmitViewUp:NO];
    }
    
    return YES;
}

- (void)animateSubmitViewUp:(BOOL)up {
    if (up) {
        [UIView animateWithDuration:0.25 animations:^{
            self.SubmitView.frame = CGRectMake(0, -1*(self.SubmitDoneEditingButton.frame.origin.y), self.SubmitView.frame.size.width, self.SubmitView.frame.size.height);
            self.SubmitDoneEditingButton.alpha = 1;
        }];
    }
    else {
        [UIView animateWithDuration:0.25 animations:^{
            self.SubmitView.frame = CGRectMake(0, 0, self.SubmitView.frame.size.width, self.SubmitView.frame.size.height);
            self.SubmitDoneEditingButton.alpha = 0;
        }];
    }
}


#pragma mark - Keyboard
- (IBAction)didSelectDoneEditing:(id)sender {
    [self hideKeyboard];
}

- (void)hideKeyboard {
    [self.SubmitView endEditing:YES];
    [self.view endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    // Get Keyboard Height
    float keyboardHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    if (self.SubmitType == SubmitHNTypePost) {
        self.SubmitSelfTextView.frame = CGRectMake(self.SubmitSelfTextView.frame.origin.x, self.SubmitSelfTextView.frame.origin.y, self.SubmitSelfTextView.frame.size.width, self.SubmitSelfTextView.frame.size.height - self.SubmitDoneEditingButton.frame.origin.y);
    }
    else {
        self.CommentTextView.frame = CGRectMake(self.CommentTextView.frame.origin.x, self.CommentTextView.frame.origin.y, self.CommentTextView.frame.size.width, self.CommentTextView.frame.size.height - keyboardHeight);
        [UIView animateWithDuration:0.25 animations:^{
            self.CommentDoneEditing.alpha = 1;
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    float keyboardHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    if (self.SubmitType == SubmitHNTypePost) {
        self.SubmitSelfTextView.frame = CGRectMake(self.SubmitSelfTextView.frame.origin.x, self.SubmitSelfTextView.frame.origin.y, self.SubmitSelfTextView.frame.size.width,self.SubmitSelfTextView.frame.size.height + self.SubmitDoneEditingButton.frame.origin.y);
    }
    else {
        self.CommentTextView.frame = CGRectMake(self.CommentTextView.frame.origin.x, self.CommentTextView.frame.origin.y, self.CommentTextView.frame.size.width, self.CommentTextView.frame.size.height + keyboardHeight);
        [UIView animateWithDuration:0.25 animations:^{
            self.CommentDoneEditing.alpha = 0;
        }];
    }
}

#pragma mark - Submit
- (void)didPressSubmit {
    [self hideKeyboard];
    if (self.HNObject) {
        [self submitComment];
    }
    else {
        [self submitPost];
    }
}

#pragma mark - Submit Post
- (void)submitPost {
    NSString *title = self.SubmitTitleTextField.text;
    NSString *link = self.SubmitLinkTextField.text.length > 0 ? self.SubmitLinkTextField.text : nil;
    NSString *text = self.SubmitSelfTextView.text.length > 0 ? self.SubmitSelfTextView.text : nil;
    [self.SubmitButton setUserInteractionEnabled:NO];
    [[HNManager sharedManager] submitPostWithTitle:title link:link text:text completion:^(BOOL success) {
        if (success) {
            [self dismissSelf];
            [KGStatusBar showWithStatus:@"Submission Success"];
        }
        else {
            [KGStatusBar showWithStatus:@"Submission Failed"];
            [self.SubmitButton setUserInteractionEnabled:YES];
        }
    }];
}


#pragma mark - Submit Comment
- (void)submitComment {
    [self.CommentSubmitButton setUserInteractionEnabled:NO];
    [[HNManager sharedManager] replyToPostOrComment:self.HNObject withText:self.CommentTextView.text completion:^(BOOL success) {
        if (success) {
            [self dismissSelf];
            [KGStatusBar showWithStatus:@"Comment Submitted"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSubmitNewComment" object:nil];
        }
        else {
            [KGStatusBar showWithStatus:@"Comment Failed"];
            [self.CommentSubmitButton setUserInteractionEnabled:YES];
        }
    }];
}


#pragma mark - Dismiss VC
- (void)dismissSelf {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
