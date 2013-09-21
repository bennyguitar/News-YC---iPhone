//
//  CommentsCell.h
//  HackerNews
//
//  Created by Benjamin Gordon on 11/7/12.
//  Copyright (c) 2012 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HNSingleton.h"
#import "Comment.h"
#import "TTTAttributedLabel.h"
#import "LinkLabel.h"

#define kCommentsHidden 20
#define kCommentsDefaultH 85
#define kCommentsDefaultW 307

@interface CommentsCell : UITableViewCell <TTTAttributedLabelDelegate> {
    
}
@property (retain, nonatomic) IBOutlet UILabel *username;
@property (retain, nonatomic) IBOutlet UILabel *postedTime;
@property (retain, nonatomic) IBOutlet TTTAttributedLabel *comment;
@property (retain, nonatomic) IBOutlet UIView *holdingView;
@property (retain, nonatomic) IBOutlet UIImageView *topBar;
@property (nonatomic, assign) int commentLevel;
@property (nonatomic, retain) NSString *postTitle;
@property (weak, nonatomic) IBOutlet UIButton *topBarButton;
@property (weak, nonatomic) IBOutlet UIView *topBarBorder;

-(CommentsCell *)cellForComment:(Comment *)newComment atIndex:(NSIndexPath *)indexPath fromController:(UIViewController *)controller;
-(float)heightForComment:(Comment *)newComment;


@end
