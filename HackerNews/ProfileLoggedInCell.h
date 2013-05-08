//
//  ProfileLoggedInCell.h
//  HackerNews
//
//  Created by Ben Gordon on 5/7/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellProfLoggedInHeight 132

@interface ProfileLoggedInCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *karmaLabel;


@end
