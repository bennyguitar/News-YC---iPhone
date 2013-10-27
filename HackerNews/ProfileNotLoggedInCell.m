//
//  ProfileNotLoggedInCell.m
//  HackerNews
//
//  Created by Ben Gordon on 5/7/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "ProfileNotLoggedInCell.h"
#import "HNSingleton.h"
#import "Helpers.h"

@implementation ProfileNotLoggedInCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Set Content
- (void)setActionsAndDelegate:(id)del {
    self.delegate = del;
    self.usernameTextField.delegate = del;
    self.passwordTextField.delegate = del;
    [self.loginButton addTarget:self action:@selector(didClickLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton setTitleColor:kOrangeColor forState:UIControlStateNormal];
}

#pragma mark - Set Actions
- (void)didClickLogin {
    // Black View
    UIView *bView = [[UIView alloc] initWithFrame:CGRectMake(0, 25, self.frame.size.width, self.frame.size.height - 25)];
    bView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
    [self addSubview:bView];
    [self.usernameTextField setUserInteractionEnabled:NO];
    [self.passwordTextField setUserInteractionEnabled:NO];
    [self.loginButton setUserInteractionEnabled:NO];
    
    if ([self.delegate respondsToSelector:@selector(didClickLoginWithUsername:password:)]) {
        [self.delegate didClickLoginWithUsername:self.usernameTextField.text password:self.passwordTextField.text];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
