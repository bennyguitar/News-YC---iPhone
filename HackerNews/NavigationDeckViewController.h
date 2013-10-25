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
#import "GetProViewController.h"
#import "HNSingleton.h"
#import "FilterCell.h"
#import "ShareCell.h"
#import "SettingsCell.h"
#import "CreditsCell.h"
#import "ProfileNotLoggedInCell.h"
#import "ProfileLoggedInCell.h"
#import "NavPurchaseProCell.h"
#import "AppDelegate.h"
#import "Helpers.h"
#import "libHN.h"

@interface NavigationDeckViewController : UIViewController <MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,NavShareCellDelegate,NavSettingsDelegate,NavProfileLoginDelegate,NavPurchaseProDelegate> {
    
    IBOutlet UITableView *navTable;
    __weak IBOutlet UIView *headerBar;
}




@end
