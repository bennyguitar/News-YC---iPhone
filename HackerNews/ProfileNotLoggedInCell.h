//
//  ProfileNotLoggedInCell.h
//  HackerNews
//
//  Created by Ben Gordon on 5/7/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellProfNotLoggedInHeight 180

@protocol NavProfileLoginDelegate <NSObject>

- (void)didClickLoginWithUsername:(NSString *)user password:(NSString *)password;

@end

@interface ProfileNotLoggedInCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak) id <NavProfileLoginDelegate> delegate;

- (void)setActionsAndDelegate:(id)del;
- (void)didClickLogin;

@end
