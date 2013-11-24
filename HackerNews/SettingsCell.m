//
//  SettingsCell.m
//  HackerNews
//
//  Created by Ben Gordon on 1/19/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "SettingsCell.h"
#import "HNManager.h"

@implementation SettingsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Set Content
- (void)addActionsToDelegate:(id)del {
    self.delegate = del;
    
    // Set Variables
    self.Readability = [[NSUserDefaults standardUserDefaults] boolForKey:@"Readability"];
    self.MarkAsRead = [[NSUserDefaults standardUserDefaults] boolForKey:@"MarkAsRead"];
    self.ThemeMode = [[NSUserDefaults standardUserDefaults] integerForKey:@"HNTheme"];
    
    // Set Images
    [self setReadabilityStatus];
    [self setMarkAsReadStatus];
    [self setThemeStatus];
    
    // Set Readability
    [self.readabilityButton addTarget:self action:@selector(didSelectReadability) forControlEvents:UIControlEventTouchUpInside];
    [self.readabilityHidden addTarget:self action:@selector(didSelectReadability) forControlEvents:UIControlEventTouchUpInside];
    
    // Set mark as read
    [self.markAsReadButton addTarget:self action:@selector(didSelectMarkAsRead) forControlEvents:UIControlEventTouchUpInside];
    [self.markAsReadHidden addTarget:self action:@selector(didSelectMarkAsRead) forControlEvents:UIControlEventTouchUpInside];
    
    // Set theme mode
    [self.nightModeButton addTarget:self action:@selector(didSelectNightMode) forControlEvents:UIControlEventTouchUpInside];
    [self.themeHidden addTarget:self action:@selector(didSelectNightMode) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Statuses
- (void)setReadabilityStatus {
    self.readabilityButton.alpha = self.Readability ? 1.0 : 0.5;
    [self.readabilityButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"nav_readability_%@-01.png", self.Readability ? @"on" : @"off"]] forState:UIControlStateNormal];
    self.readabilityLabel.text = [NSString stringWithFormat:@"Readability is %@", (self.Readability ? @"ON" : @"OFF")];
    [[NSUserDefaults standardUserDefaults] setBool:self.Readability forKey:@"Readability"];
}

- (void)setMarkAsReadStatus {
    self.markAsReadButton.alpha = self.MarkAsRead ? 1.0 : 0.5;
    [self.markAsReadButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"nav_markasread_%@-01.png", self.MarkAsRead ? @"on" : @"off"]] forState:UIControlStateNormal];
    self.markAsReadLabel.text = [NSString stringWithFormat:@"Mark As Read is %@", (self.MarkAsRead ? @"ON" : @"OFF")];
    [[NSUserDefaults standardUserDefaults] setBool:self.MarkAsRead forKey:@"MarkAsRead"];
}

- (void)setThemeStatus {
    self.nightModeButton.alpha = 1;
    [self.nightModeButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"nav_%@_on-01.png", self.ThemeMode == HNThemeTypeNight ? @"nightmode" : @"daymode"]] forState:UIControlStateNormal];
    self.themeLabel.text = [NSString stringWithFormat:@"Theme is %@", (self.ThemeMode == HNThemeTypeNight ? @"NIGHT" : @"DAY")];
    [[NSUserDefaults standardUserDefaults] setInteger:self.ThemeMode forKey:@"HNTheme"];
}


#pragma mark - Actions
- (void)didSelectReadability {
    // Change Readbility status
    self.Readability = self.Readability ? NO : YES;
    [self setReadabilityStatus];
    
    // Delegate Change
    if ([self.delegate respondsToSelector:@selector(didClickReadability:)]) {
        [self.delegate didClickReadability:self.Readability];
    }
}

- (void)didSelectMarkAsRead {
    // Change Readbility status
    self.MarkAsRead = self.MarkAsRead ? NO : YES;
    [self setMarkAsReadStatus];
    
    // Delegate Change
    if ([self.delegate respondsToSelector:@selector(didClickMarkAsRead:)]) {
        [self.delegate didClickMarkAsRead:self.MarkAsRead];
    }
}

- (void)didSelectNightMode {
    // Change Readbility status
    self.ThemeMode = self.ThemeMode == HNThemeTypeNight ? HNThemeTypeDay : HNThemeTypeNight;
    [self setThemeStatus];
    
    // Delegate Change
    if ([self.delegate respondsToSelector:@selector(didClickChangeTheme:)]) {
        [self.delegate didClickChangeTheme:self.ThemeMode];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
