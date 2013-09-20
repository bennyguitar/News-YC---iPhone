//
//  FilterCell.m
//  HackerNews
//
//  Created by Ben Gordon on 1/19/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "FilterCell.h"
#import "ViewController.h"
#import "AppDelegate.h"

@implementation FilterCell
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)buildUI {

}

- (void)setUpCellForActiveFilter:(int)filter delegate:(id)vcDelegate {
    NSArray *buttons = @[self.topButton, self.askButton, self.newestButton, self.jobsButton, self.bestButton];
    if (vcDelegate) {
        delegate = (id <FilterCellDelegate>)vcDelegate;
    }
    
    for (UIButton *button in buttons) {
        [button setTitleColor:(button.tag == filter ? kOrangeColor : [UIColor colorWithWhite:0.5 alpha:1.0]) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(didClickFilterButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)didClickFilterButton:(UIButton *)button {
    [delegate filterHomePageWithType:button.tag];
    [self setUpCellForActiveFilter:button.tag delegate:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end
