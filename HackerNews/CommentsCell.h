//
//  CommentsCell.h
//  HackerNews
//
//  Created by Benjamin Gordon on 11/7/12.
//  Copyright (c) 2012 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HNComment.h"
#import "HNTheme.h"
#import "TTTAttributedLabel.h"
#import "LinkLabel.h"
#import "triangleView.h"

#define kCommentsHidden 20
#define kCommentsDefaultH 85
#define kCommentsDefaultW 307
#define kCommentDefaultAddition 45
#define kCommentAskHNAddition 56
#define kCommentAuxiliaryHeight 44

@protocol CommentCellDelegate <NSObject>

- (void)didClickShareCommentAtIndex:(NSInteger)index;
- (void)didClickReplyToCommentAtIndex:(NSInteger)index;
- (void)didClickUpvoteCommentAtIndex:(NSInteger)index;
- (void)didClickDownvoteCommentAtIndex:(NSInteger)index;

@end

@interface CommentsCell : UITableViewCell <TTTAttributedLabelDelegate> {
}

@property (nonatomic, assign) NSInteger Index;
@property (retain, nonatomic) IBOutlet UILabel *username;
@property (retain, nonatomic) IBOutlet UILabel *postedTime;
@property (retain, nonatomic) IBOutlet TTTAttributedLabel *comment;
@property (retain, nonatomic) IBOutlet UIView *holdingView;
@property (retain, nonatomic) IBOutlet UIImageView *topBar;
@property (nonatomic, assign) int commentLevel;
@property (nonatomic, retain) NSString *postTitle;
@property (weak, nonatomic) IBOutlet UIButton *topBarButton;
@property (weak, nonatomic) IBOutlet UIView *topBarBorder;
@property (nonatomic, assign) BOOL isClicked;
@property (weak, nonatomic) IBOutlet UIView *auxiliaryView;
@property (weak, nonatomic) IBOutlet UIButton *auxiliaryShareButton;
@property (weak, nonatomic) IBOutlet UIButton *auxiliaryCommentButton;
@property (weak, nonatomic) IBOutlet UIButton *auxiliaryUpvoteButton;
@property (weak, nonatomic) IBOutlet UIButton *auxiliaryDownvoteButton;
@property (weak, nonatomic) IBOutlet UIView *auxiliarySeparator;

@property (weak) id <CommentCellDelegate> delegate;

-(CommentsCell *)cellForComment:(HNComment *)newComment atIndex:(NSIndexPath *)indexPath fromController:(UIViewController *)controller postOP:(NSString *)postOP  showAuxiliary:(BOOL)auxiliary;
+ (float)heightForComment:(HNComment *)newComment isAuxiliary:(BOOL)auxiliary;

@end
