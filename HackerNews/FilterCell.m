//
//  FilterCell.m
//  HackerNews
//
//  Created by Ben Gordon on 1/19/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "FilterCell.h"

@implementation FilterCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self buildUI];
    }
    return self;
}

-(void)buildUI {
    NSArray *bArray = @[self.filterTopButton,self.filterNewButton, self.filterAskButton];
    for (UIButton *b in bArray) {
        b.layer.cornerRadius = 10;
        b.layer.shadowColor = [UIColor blackColor].CGColor;
        b.layer.shadowOpacity = 0.4f;
        b.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        b.layer.shadowRadius = 2.75f;
        b.layer.masksToBounds = NO;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:b.bounds cornerRadius:10];
        b.layer.shadowPath = path.CGPath;
    }
    
    self.filterTopOverlay.layer.cornerRadius = 7;
    self.filterNewOverlay.layer.cornerRadius = 7;
    self.filterAskOverlay.layer.cornerRadius = 7;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end
