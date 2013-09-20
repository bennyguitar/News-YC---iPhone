//
//  FilterCell.h
//  HackerNews
//
//  Created by Ben Gordon on 1/19/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define kFilterCellHeight 128

@class ViewController;

@protocol FilterCellDelegate <NSObject>
- (void)filterHomePageWithType:(int)type;
@end

@interface FilterCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *topButton;
@property (weak, nonatomic) IBOutlet UIButton *askButton;
@property (weak, nonatomic) IBOutlet UIButton *newestButton;
@property (weak, nonatomic) IBOutlet UIButton *jobsButton;
@property (weak, nonatomic) IBOutlet UIButton *bestButton;
@property (weak) id <FilterCellDelegate> delegate;

- (void)setUpCellForActiveFilter:(int)filter delegate:(id)vcDelegate;

@end
