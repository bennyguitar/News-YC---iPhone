//
//  ProfileLoggedInCell.h
//  HackerNews
//
//  Created by Ben Gordon on 5/7/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellProfLoggedInHeight 183

@protocol NavProfileDelegate <NSObject>

- (void)didClickLogout;
- (void)didClickMySubmissions;

@end

@interface ProfileLoggedInCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *karmaLabel;
@property (weak, nonatomic) IBOutlet UIButton *MySubmissionsButton;
@property (weak, nonatomic) IBOutlet UIButton *LogoutButton;

@property (weak) id <NavProfileDelegate> delegate;

- (void)setCellContentWithDelegate:(id)del;

@end
