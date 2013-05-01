//
//  ShareCell.h
//  HackerNews
//
//  Created by Ben Gordon on 1/19/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIButton *fbButton;
@property (retain, nonatomic) IBOutlet UIButton *twitterButton;
@property (retain, nonatomic) IBOutlet UIButton *emailButton;
@property (retain, nonatomic) IBOutlet UIImageView *checkImage;

@end
