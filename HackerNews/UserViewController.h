//
//  UserViewController.h
//  HackerNews
//
//  Created by Benjamin Gordon on 5/5/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "IIViewDeckController.h"
#import "HNSingleton.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "Webservice.h"
#import "User.h"

@interface UserViewController : ViewController <UITextFieldDelegate,WebserviceDelegate> {
    
    // Login
    __weak IBOutlet UITextField *usernameTextField;
    __weak IBOutlet UITextField *passwordTextField;
    __weak IBOutlet UIButton *submitButton;
}


- (IBAction)didClickLogin:(id)sender;

@end
