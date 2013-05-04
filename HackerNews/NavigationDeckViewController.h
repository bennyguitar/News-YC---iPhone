//
//  NavigationDeckViewController.h
//  HackerNews
//
//  Created by Benjamin Gordon on 1/10/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import "IIViewDeckController.h"
#import "ViewController.h"
#import "HNSingleton.h"
#import "FilterCell.h"
#import "ShareCell.h"
#import "SettingsCell.h"
#import "CreditsCell.h"
#import "AppDelegate.h"
#import "Helpers.h"

@interface NavigationDeckViewController : UIViewController <MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UITableView *navTable;
    IBOutlet UILabel *errorLabel;
}

- (IBAction)changeTypeToTop:(id)sender;
- (IBAction)changeTypeToNew:(id)sender;
- (IBAction)changeTypeToAsk:(id)sender;


- (IBAction)didClickShareToFacebook:(id)sender;
- (IBAction)didClickShareToTwitter:(id)sender;
- (IBAction)didClickShareToEmail:(id)sender;




@end
