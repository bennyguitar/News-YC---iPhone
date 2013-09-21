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

- (void)setUpCellForActiveFilter {
    NSArray *buttons = @[self.topButton, self.askButton, self.newestButton, self.jobsButton, self.bestButton];
    AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *navVC = (UINavigationController *)del.deckController.centerController;
    ViewController *vc = (ViewController *)[navVC viewControllers][0];
    
    for (UIButton *button in buttons) {
        [button setTitleColor:(button.tag == vc.filterType ? kOrangeColor : [UIColor colorWithWhite:0.5 alpha:1.0]) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(didClickFilterButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)didClickFilterButton:(UIButton *)button {
    AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    ViewController *vc = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil filterType:button.tag];
    [del.deckController setCenterController:[[UINavigationController alloc] initWithRootViewController:vc]];
    [del.deckController toggleLeftView];
    [self setUpCellForActiveFilter];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end
