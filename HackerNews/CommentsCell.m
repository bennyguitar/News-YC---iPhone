//
//  CommentsCell.m
//  HackerNews
//
//  Created by Benjamin Gordon on 11/7/12.
//  Copyright (c) 2012 Benjamin Gordon. All rights reserved.
//

#import "CommentsCell.h"
#import "libHN.h"
#import <QuartzCore/QuartzCore.h>
#import "TTTAttributedLabel.h"
#import "LinkLabel.h"

@implementation CommentsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:NO animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:NO animated:animated];
}

-(CommentsCell *)cellForComment:(HNComment *)newComment atIndex:(NSIndexPath *)indexPath fromController:(UIViewController *)controller showAuxiliary:(BOOL)auxiliary {
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    
    // Color cell elements
    self.comment.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"MainFont"];
    self.comment.backgroundColor = [[HNSingleton sharedHNSingleton] themeDict][@"CellBG"];
    self.username.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"SubFont"];
    self.username.backgroundColor = [[HNSingleton sharedHNSingleton] themeDict][@"BottomBar"];
    self.postedTime.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"SubFont"];
    self.postedTime.backgroundColor = [[HNSingleton sharedHNSingleton] themeDict][@"BottomBar"];
    self.topBar.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"BottomBar"];
    self.comment.opaque = YES;
    self.username.opaque = YES;
    self.postedTime.opaque = YES;
    
    if (newComment) {
        // Set Data to UI Elements
        self.commentLevel = newComment.Level;
        self.username.text = newComment.Username;
        self.postedTime.text = newComment.TimeCreatedString;
        self.holdingView.frame = CGRectMake(15 * newComment.Level, 0, self.frame.size.width - (15*newComment.Level), self.frame.size.height);
        
        self.delegate = (id <CommentCellDelegate>)controller;
        self.Index = indexPath.row;
        
        // Set Border based on CellType
        self.topBarBorder.alpha = 0;
        //[self.comment setAttributedText:newComment.attrText];
        
        // Set Attributed Text
        [self.comment setText:newComment.Text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            for (HNCommentLink *link in newComment.Links) {
                if (newComment.Type == CommentTypeJobs || newComment.Type == CommentTypeAskHN) {
                    [mutableAttributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:link.UrlRange];
                }
                else {
                    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:kOrangeColor range:link.UrlRange];
                    [mutableAttributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:link.UrlRange];
                }
            }
            return mutableAttributedString;
        }];
        
        // Set line height
        [self.comment setLineHeightMultiple:1.0];
        self.comment.leading = 1.0;
        self.comment.numberOfLines = 0;
        
        
        // Set size of Comment Label
        CGSize labelSize = CGSizeMake(307 - (newComment.Level*15), 0);
        labelSize = [self.comment sizeThatFits:labelSize];
        self.comment.frame = CGRectMake(self.comment.frame.origin.x, self.comment.frame.origin.y, labelSize.width, labelSize.height);
        self.holdingView.frame = CGRectMake(self.holdingView.frame.origin.x, self.holdingView.frame.origin.y, self.holdingView.frame.size.width, labelSize.height + kCommentDefaultAddition);
        
        // Add links
        for (HNCommentLink *link in newComment.Links) {
            [self.comment addLinkToURL:link.Url withRange:link.UrlRange];
        }
        
        // Check for Ask HN or HN Jobs
        if (newComment.Type == CommentTypeAskHN || newComment.Type == CommentTypeJobs) {
            self.topBar.backgroundColor = [HNSingleton sharedHNSingleton].themeDict[(newComment.Type == CommentTypeAskHN ? @"ShowHNBottom" : @"HNJobsBottom")];
            self.postedTime.backgroundColor = [HNSingleton sharedHNSingleton].themeDict[(newComment.Type == CommentTypeAskHN ? @"ShowHNBottom" : @"HNJobsBottom")];
            self.username.backgroundColor = [HNSingleton sharedHNSingleton].themeDict[(newComment.Type == CommentTypeAskHN ? @"ShowHNBottom" : @"HNJobsBottom")];
            self.holdingView.backgroundColor = [[HNSingleton sharedHNSingleton] themeDict][(newComment.Type == CommentTypeAskHN ? @"ShowHN" : @"HNJobs")];
            self.comment.backgroundColor = [[HNSingleton sharedHNSingleton] themeDict][(newComment.Type == CommentTypeAskHN ? @"ShowHN" : @"HNJobs")];
            self.backgroundColor = [[HNSingleton sharedHNSingleton] themeDict][(newComment.Type == CommentTypeAskHN ? @"ShowHN" : @"HNJobs")];
            
            // Triangle
            TriangleView *triangle = [[TriangleView alloc] initWithFrame:CGRectMake(0, self.comment.frame.origin.y + labelSize.height + 10, self.frame.size.width, 6)];
            [triangle setColor:[HNSingleton sharedHNSingleton].themeDict[(newComment.Type == CommentTypeAskHN ? @"ShowHNBottom" : @"HNJobsBottom")]];
            [triangle drawTriangleAtXPosition:(self.frame.size.width/2)];
            triangle.backgroundColor = [[HNSingleton sharedHNSingleton] themeDict][(newComment.Type == CommentTypeAskHN ? @"ShowHN" : @"HNJobs")];
            [self.holdingView addSubview:triangle];
            
            // Bar
            UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, triangle.frame.origin.y + triangle.frame.size.height, self.frame.size.width, 12)];
            barView.backgroundColor = [HNSingleton sharedHNSingleton].themeDict[(newComment.Type == CommentTypeAskHN ? @"ShowHNBottom" : @"HNJobsBottom")];
            [self.holdingView addSubview:barView];
            
            // Separator
            UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, barView.frame.origin.y + barView.frame.size.height, self.frame.size.width, 1)];
            separator.backgroundColor = [HNSingleton sharedHNSingleton].themeDict[@"Separator"];
            [self.holdingView addSubview:separator];
            
            // Holding View
            self.holdingView.frame = CGRectMake(self.holdingView.frame.origin.x, self.holdingView.frame.origin.y, self.holdingView.frame.size.width, separator.frame.origin.y + separator.frame.size.height);
            
            if ([self respondsToSelector:@selector(contentView)]) {
                self.contentView.frame = self.holdingView.frame;
            }
            self.frame = self.holdingView.frame;
        }
        
        // Auxiliary View
        if (auxiliary && (newComment.Type != CommentTypeJobs)) {
            self.auxiliaryView.backgroundColor = [[HNSingleton sharedHNSingleton] themeDict][@"ShowHN"];
            self.auxiliarySeparator.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"BottomBar"];
            self.auxiliaryView.frame = CGRectMake(0, self.holdingView.frame.size.height, self.holdingView.frame.size.width, kCommentAuxiliaryHeight);
            [self.holdingView addSubview:self.auxiliaryView];
            self.holdingView.frame = CGRectMake(self.holdingView.frame.origin.x, self.holdingView.frame.origin.y, self.holdingView.frame.size.width, self.holdingView.frame.size.height + kCommentAuxiliaryHeight);
            
            // Set Actions
            [self.auxiliaryShareButton addTarget:self action:@selector(didClickShare) forControlEvents:UIControlEventTouchUpInside];
            [self.auxiliaryCommentButton addTarget:self action:@selector(didClickComment) forControlEvents:UIControlEventTouchUpInside];
            [self.auxiliaryUpvoteButton addTarget:self action:@selector(didClickUpvote) forControlEvents:UIControlEventTouchUpInside];
            
            // Downvote
            if ([HNManager sharedManager].SessionUser.Karma >= 500) {
                [self.auxiliaryDownvoteButton addTarget:self action:@selector(didClickDownvote) forControlEvents:UIControlEventTouchUpInside];
            }
            else {
                [self.auxiliaryDownvoteButton setUserInteractionEnabled:NO];
                self.auxiliaryDownvoteButton.alpha = 0.25;
            }
        }
        
        // Set action of topBarButton
        /*
        self.topBarButton.tag = indexPath.row;
        [self.topBarButton addTarget:controller action:@selector(hideNestedCommentsCell:) forControlEvents:UIControlEventTouchDownRepeat];
         */
        
        // Set Tags and Actions of Other Buttons
    }
    else {
        // No comments
        self.username.text = @"";
        self.postedTime.text = @"";
        self.comment.text = @"Ahh! Looks like no comments exist!";
        [self.comment setTextAlignment:NSTextAlignmentCenter];
    }
    
    return self;
}

-(float)heightForComment:(HNComment *)newComment isAuxiliary:(BOOL)auxiliary {
    if (newComment) {
        // Comment is Open
        self.comment.text = newComment.Text;
        // Set size of Comment Label
        CGSize labelSize = CGSizeMake(307 - (newComment.Level*15), 0);
        labelSize = [self.comment sizeThatFits:labelSize];
        return labelSize.height + (newComment.Type == CommentTypeAskHN || newComment.Type == CommentTypeJobs ? kCommentAskHNAddition : kCommentDefaultAddition) + (auxiliary ? kCommentAuxiliaryHeight : 0);
    }

    // No Comments
    return kCommentsDefaultH;
}



-(void)drawRect:(CGRect)rect {
    // Add the line that designated nested Comments
    for (int xx = 0; xx < self.commentLevel + 1; xx++) {
        if (xx != 0) {
            UIBezierPath *path = [UIBezierPath bezierPath];
            [[[HNSingleton sharedHNSingleton].themeDict objectForKey:@"BottomBar"] setStroke];
            [path moveToPoint:CGPointMake(15*xx, 0)];
            [path addLineToPoint:CGPointMake(15*xx, self.frame.size.height)];
            [path stroke];
        }
    }
}


#pragma mark - Auxiliary Actions
- (void)didClickShare {
    if ([self.delegate respondsToSelector:@selector(didClickShareCommentAtIndex:)]) {
        [self.delegate didClickShareCommentAtIndex:self.Index];
    }
}

- (void)didClickComment {
    if ([self.delegate respondsToSelector:@selector(didClickReplyToCommentAtIndex:)]) {
        [self.delegate didClickReplyToCommentAtIndex:self.Index];
    }
}

- (void)didClickUpvote {
    if ([self.delegate respondsToSelector:@selector(didClickUpvoteCommentAtIndex:)]) {
        [self.delegate didClickUpvoteCommentAtIndex:self.Index];
    }
}

- (void)didClickDownvote {
    if ([self.delegate respondsToSelector:@selector(didClickDownvoteCommentAtIndex:)]) {
        [self.delegate didClickDownvoteCommentAtIndex:self.Index];
    }
}

@end
