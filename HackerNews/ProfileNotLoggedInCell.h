//
//  ProfileNotLoggedInCell.h
//  HackerNews
//
//  Created by Ben Gordon on 5/7/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellProfNotLoggedInHeight 180

@interface ProfileNotLoggedInCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end
