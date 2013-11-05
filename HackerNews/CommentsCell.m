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
#import "Helpers.h"

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
    if ([self respondsToSelector:@selector(separatorInset)]) {
        self.separatorInset = UIEdgeInsetsZero;
    }
    
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
        self.Index = indexPath ? indexPath.row : 0;
        
        // Set Border based on CellType
        self.topBarBorder.alpha = 0;
        //[self.comment setAttributedText:newComment.attrText];
        
        // Set Attributed Text
        [self.comment setText:newComment.Text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            mutableAttributedString = [[CommentsCell attributedStringForComment:newComment] mutableCopy];
            return mutableAttributedString;
        }];
        
        // Set size of Comment Label
        CGSize labelSize = CGSizeMake(((UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height) - 13) - (newComment.Level*15), [CommentsCell heightForAttributedString:[CommentsCell attributedStringForComment:newComment] inSize:CGSizeMake(((UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height) - 13) - (newComment.Level*15), MAXFLOAT)]);
        self.comment.frame = CGRectMake(self.comment.frame.origin.x, self.comment.frame.origin.y, ceilf(labelSize.width), ceilf(labelSize.height));
        self.holdingView.frame = CGRectMake(self.holdingView.frame.origin.x, self.holdingView.frame.origin.y, self.holdingView.frame.size.width, self.comment.frame.size.height + kCommentDefaultAddition);
        
        // Add links
        for (HNCommentLink *link in newComment.Links) {
            [self.comment addLinkToURL:link.Url withRange:link.UrlRange];
        }
        
        // Check for Ask HN or HN Jobs
        if (newComment.Type == HNCommentTypeAskHN || newComment.Type == HNCommentTypeJobs) {
            self.topBar.backgroundColor = [HNSingleton sharedHNSingleton].themeDict[(newComment.Type == HNCommentTypeAskHN ? @"ShowHNBottom" : @"HNJobsBottom")];
            self.postedTime.backgroundColor = [HNSingleton sharedHNSingleton].themeDict[(newComment.Type == HNCommentTypeAskHN ? @"ShowHNBottom" : @"HNJobsBottom")];
            self.username.backgroundColor = [HNSingleton sharedHNSingleton].themeDict[(newComment.Type == HNCommentTypeAskHN ? @"ShowHNBottom" : @"HNJobsBottom")];
            self.holdingView.backgroundColor = [[HNSingleton sharedHNSingleton] themeDict][(newComment.Type == HNCommentTypeAskHN ? @"ShowHN" : @"HNJobs")];
            self.comment.backgroundColor = [[HNSingleton sharedHNSingleton] themeDict][(newComment.Type == HNCommentTypeAskHN ? @"ShowHN" : @"HNJobs")];
            self.backgroundColor = [[HNSingleton sharedHNSingleton] themeDict][(newComment.Type == HNCommentTypeAskHN ? @"ShowHN" : @"HNJobs")];
            
            // Triangle
            TriangleView *triangle = [[TriangleView alloc] initWithFrame:CGRectMake(0, self.comment.frame.origin.y + labelSize.height + 10, (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height), 6)];
            [triangle setColor:[HNSingleton sharedHNSingleton].themeDict[(newComment.Type == HNCommentTypeAskHN ? @"ShowHNBottom" : @"HNJobsBottom")]];
            [triangle drawTriangleAtXPosition:(self.frame.size.width/2)];
            triangle.backgroundColor = [[HNSingleton sharedHNSingleton] themeDict][(newComment.Type == HNCommentTypeAskHN ? @"ShowHN" : @"HNJobs")];
            [self.holdingView addSubview:triangle];
            
            // Bar
            UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, triangle.frame.origin.y + triangle.frame.size.height, (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height), 12)];
            barView.backgroundColor = [HNSingleton sharedHNSingleton].themeDict[(newComment.Type == HNCommentTypeAskHN ? @"ShowHNBottom" : @"HNJobsBottom")];
            [self.holdingView addSubview:barView];
            
            // Separator
            UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, barView.frame.origin.y + barView.frame.size.height, (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height), 1)];
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
        if (auxiliary && (newComment.Type != HNCommentTypeJobs)) {
            self.auxiliaryView.backgroundColor = [[HNSingleton sharedHNSingleton] themeDict][@"ShowHN"];
            self.auxiliarySeparator.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"BottomBar"];
            self.auxiliaryView.frame = CGRectMake(0, self.holdingView.frame.size.height, self.holdingView.frame.size.width, kCommentAuxiliaryHeight);
            [self.holdingView addSubview:self.auxiliaryView];
            self.holdingView.frame = CGRectMake(self.holdingView.frame.origin.x, self.holdingView.frame.origin.y, self.holdingView.frame.size.width, self.holdingView.frame.size.height + kCommentAuxiliaryHeight);
            
            // Set Actions
            [self.auxiliaryShareButton addTarget:self action:@selector(didClickShare) forControlEvents:UIControlEventTouchUpInside];
            
            if ([[HNManager sharedManager] userIsLoggedIn]) {
                [self.auxiliaryCommentButton addTarget:self action:@selector(didClickComment) forControlEvents:UIControlEventTouchUpInside];
            }
            else {
                [self.auxiliaryCommentButton setUserInteractionEnabled:NO];
                self.auxiliaryCommentButton.alpha = 0.25;
            }
            
            // Set upvotes and downvotes
            if (newComment.UpvoteURLAddition && ![[HNManager sharedManager] hasVotedOnObject:newComment] && [[HNManager sharedManager] userIsLoggedIn]) {
                [self.auxiliaryUpvoteButton addTarget:self action:@selector(didClickUpvote) forControlEvents:UIControlEventTouchUpInside];
                
                if (newComment.DownvoteURLAddition) {
                    [self.auxiliaryDownvoteButton addTarget:self action:@selector(didClickDownvote) forControlEvents:UIControlEventTouchUpInside];
                }
                else {
                    [self.auxiliaryDownvoteButton setUserInteractionEnabled:NO];
                    self.auxiliaryDownvoteButton.alpha = 0.25;
                }
            }
            else {
                // Cannot Vote on Object!
                [self setUserCannotVoteOnObject];
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

- (void)setUserCannotVoteOnObject {
    [self.auxiliaryUpvoteButton setUserInteractionEnabled:NO];
    [self.auxiliaryDownvoteButton setUserInteractionEnabled:NO];
    self.auxiliaryUpvoteButton.alpha = 0.25;
    self.auxiliaryDownvoteButton.alpha = 0.25;
}

+ (float)heightForComment:(HNComment *)newComment isAuxiliary:(BOOL)auxiliary {
    if (newComment) {
        NSLog(@"%f", [CommentsCell heightForAttributedString:[CommentsCell attributedStringForComment:newComment] inSize:CGSizeMake(((UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height) - 13) - (newComment.Level*15), MAXFLOAT)] + (newComment.Type == HNCommentTypeAskHN || newComment.Type == HNCommentTypeJobs ? kCommentAskHNAddition : kCommentDefaultAddition) + (auxiliary ? kCommentAuxiliaryHeight : 0));
        NSLog(@"%d",UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation));
        return [CommentsCell heightForAttributedString:[CommentsCell attributedStringForComment:newComment] inSize:CGSizeMake(((UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height) - 13) - (newComment.Level*15), MAXFLOAT)] + (newComment.Type == HNCommentTypeAskHN || newComment.Type == HNCommentTypeJobs ? kCommentAskHNAddition : kCommentDefaultAddition) + (auxiliary ? kCommentAuxiliaryHeight : 0);
    }
    
    // No Comments
    return kCommentsDefaultH;
}

+ (NSAttributedString *)attributedStringForComment:(HNComment *)newComment {
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:newComment.Text];
    
    // Background Color
    [mutableAttributedString addAttribute:NSBackgroundColorAttributeName value:[[HNSingleton sharedHNSingleton] themeDict][@"CellBG"] range:NSMakeRange(0, newComment.Text.length)];
    
    // Font Color
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[[HNSingleton sharedHNSingleton] themeDict][@"MainFont"] range:NSMakeRange(0, newComment.Text.length)];
    
    // Paragraph Style
    NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];
    pStyle.lineBreakMode = NSLineBreakByWordWrapping;
    pStyle.tailIndent = 0;
    pStyle.headIndent = 0;
    pStyle.paragraphSpacing = 0.0;
    pStyle.lineSpacing = 0.0;
    pStyle.lineHeightMultiple = 0.0;
    pStyle.minimumLineHeight = 16;
    pStyle.maximumLineHeight = 16;
    [mutableAttributedString addAttribute:NSParagraphStyleAttributeName value:pStyle range:NSMakeRange(0, newComment.Text.length)];
    
    // Font
    [mutableAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, newComment.Text.length)];
    
    // Add Links
    for (HNCommentLink *link in newComment.Links) {
        if (newComment.Type == HNCommentTypeJobs || newComment.Type == HNCommentTypeAskHN) {
            [mutableAttributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:link.UrlRange];
        }
        else {
            [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:kOrangeColor range:link.UrlRange];
            [mutableAttributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:link.UrlRange];
        }
    }
    
    return mutableAttributedString;
}

+ (float)heightForAttributedString:(NSAttributedString *)attributedString inSize:(CGSize)size {
    return ceilf([attributedString boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height);
}

+ (NSDictionary *)attributesForComment:(HNComment *)comment {
    NSMutableDictionary *attributes = [@{} mutableCopy];
    [attributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [attributes setObject:[UIFont systemFontOfSize:14] forKey:NSFontAttributeName];
    NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];
    pStyle.lineBreakMode = NSLineBreakByWordWrapping;
    [attributes setObject:pStyle forKey:NSParagraphStyleAttributeName];
    
    return attributes;
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
        [self setUserCannotVoteOnObject];
        [self.delegate didClickUpvoteCommentAtIndex:self.Index];
    }
}

- (void)didClickDownvote {
    if ([self.delegate respondsToSelector:@selector(didClickDownvoteCommentAtIndex:)]) {
        [self setUserCannotVoteOnObject];
        [self.delegate didClickDownvoteCommentAtIndex:self.Index];
    }
}

@end
