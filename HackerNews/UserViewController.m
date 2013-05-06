//
//  UserViewController.m
//  HackerNews
//
//  Created by Benjamin Gordon on 5/5/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "UserViewController.h"

@interface UserViewController ()

@end

@implementation UserViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Login
- (IBAction)didClickLogin:(id)sender {
    Webservice *service = [[Webservice alloc] init];
    service.delegate = self;
    [service loginWithUsername:usernameTextField.text password:passwordTextField.text];
}

-(void)didLoginWithUser:(User *)user {
    if (user) {
        // Login Worked
        
    }
    else {
        // Login Failed
    }
}

#pragma mark - TextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end
