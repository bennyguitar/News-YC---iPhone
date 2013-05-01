//
//  frontPageCell.m
//  HackerNews
//
//  Created by Benjamin Gordon on 11/6/12.
//  Copyright (c) 2012 Benjamin Gordon. All rights reserved.
//

#import "frontPageCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation frontPageCell
@synthesize titleLabel, postedTimeLabel, scoreLabel, commentsLabel, authorLabel, commentTagButton, commentBGButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //self.scoreLabel.alpha = 1;
        //self.postedTimeLabel.alpha = 1;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:NO];
}

@end
