//
//  ProfileLoggedInCell.m
//  HackerNews
//
//  Created by Ben Gordon on 5/7/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//
#import "HNManager.h"
#import "ProfileLoggedInCell.h"
#import "HNSingleton.h"

@implementation ProfileLoggedInCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setCellContentWithDelegate:(id)del {
    self.delegate = del;
    [self.MySubmissionsButton addTarget:self action:@selector(fetchMySubmissions) forControlEvents:UIControlEventTouchUpInside];
    [self.LogoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    self.userLabel.text = [HNManager sharedManager].SessionUser.Username;
    self.karmaLabel.text = [NSString stringWithFormat:@"%d Karma", [HNManager sharedManager].SessionUser.Karma];
    [self.LogoutButton setTitleColor:kOrangeColor forState:UIControlStateNormal];
    [self.MySubmissionsButton setTitleColor:kOrangeColor forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - Actions
- (void)logout {
    if ([self.delegate respondsToSelector:@selector(didClickLogout)]) {
        [self.delegate didClickLogout];
    }
}

- (void)fetchMySubmissions {
    if ([self.delegate respondsToSelector:@selector(didClickMySubmissions)]) {
        [self.delegate didClickMySubmissions];
    }
}

@end
