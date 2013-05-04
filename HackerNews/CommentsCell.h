//
//  CommentsCell.h
//  HackerNews
//
//  Created by Benjamin Gordon on 11/7/12.
//  Copyright (c) 2012 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HNSingleton.h"

#define kCommentsHidden 20

@interface CommentsCell : UITableViewCell {
    
}
@property (retain, nonatomic) IBOutlet UILabel *username;
@property (retain, nonatomic) IBOutlet UILabel *postedTime;
@property (retain, nonatomic) IBOutlet UILabel *comment;
@property (retain, nonatomic) IBOutlet UIView *holdingView;
@property (retain, nonatomic) IBOutlet UIImageView *topBar;
@property (nonatomic, assign) int commentLevel;
@property (nonatomic, retain) NSString *postTitle;
@property (weak, nonatomic) IBOutlet UIButton *topBarButton;
@property (weak, nonatomic) IBOutlet UIView *topBarBorder;


@end
