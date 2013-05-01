//
//  FilterCell.h
//  HackerNews
//
//  Created by Ben Gordon on 1/19/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface FilterCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIButton *filterTopButton;
@property (retain, nonatomic) IBOutlet UIButton *filterNewButton;
@property (retain, nonatomic) IBOutlet UIButton *filterAskButton;
@property (retain, nonatomic) IBOutlet UIImageView *filterNewOverlay;
@property (retain, nonatomic) IBOutlet UIImageView *filterTopOverlay;
@property (retain, nonatomic) IBOutlet UIImageView *filterAskOverlay;


@end
