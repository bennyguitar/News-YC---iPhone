//
//  frontPageCell.m
//  HackerNews
//
//  Created by Benjamin Gordon on 11/6/12.
//  Copyright (c) 2012 Benjamin Gordon. All rights reserved.
//

#import "frontPageCell.h"
#import <QuartzCore/QuartzCore.h>
#import "HNTheme.h"
#import "Helpers.h"
#import "libHN.h"

@implementation frontPageCell
@synthesize titleLabel, postedTimeLabel, scoreLabel, commentsLabel, authorLabel, commentTagButton, commentBGButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //self.scoreLabel.alpha = 1;
        //self.postedTimeLabel.alpha = 1;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:NO animated:YES];
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:NO animated:YES];
}


-(frontPageCell *)setCellWithPost:(HNPost *)post atIndex:(NSIndexPath *)indexPath fromController:(UIViewController *)controller {
    if (post) {
        // Set data
        self.titleLabel.text = post.Title;
        NSString *timeAgo = post.TimeCreatedString;
        self.postedTimeLabel.text = [NSString stringWithFormat:@"%@ by %@", timeAgo, post.Username];
        self.commentsLabel.text = [NSString stringWithFormat:@"%d", post.CommentCount];
        self.scoreLabel.text = [NSString stringWithFormat:@"%d Point%@", post.Points, post.Points == 1 ? @"" : @"s"];
        self.commentTagButton.tag = indexPath.row;
        self.commentBGButton.tag = indexPath.row;
        [self.commentTagButton addTarget:controller action:@selector(didClickCommentsFromHomepage:) forControlEvents:UIControlEventTouchUpInside];
        [self.commentBGButton addTarget:controller action:@selector(didClickCommentsFromHomepage:) forControlEvents:UIControlEventTouchUpInside];
        
        // Color cell elements
        self.titleLabel.textColor = [HNTheme colorForElement:@"MainFont"];
        self.postedTimeLabel.textColor = [HNTheme colorForElement:@"SubFont"];
        self.scoreLabel.textColor = [HNTheme colorForElement:@"SubFont"];
        self.bottomBar.backgroundColor = [HNTheme colorForElement:@"BottomBar"];
        [self.commentTagButton setImage:[HNTheme imageForKey:@"CommentBubble"] forState:UIControlStateNormal];
        
        // Show HN Color
        if (self.titleLabel.text.length >= 9) {
            if ([[self.titleLabel.text substringWithRange:NSMakeRange(0, 9)] isEqualToString:@"Show HN: "]) {
                self.backgroundColor = [HNTheme colorForElement:@"ShowHN"];
                self.bottomBar.backgroundColor = [HNTheme colorForElement:@"ShowHNBottom"];
            }
        }
        
        // Jobs Color
        if (post.Type == PostTypeJobs) {
            UIView *jobsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            jobsView.backgroundColor = [HNTheme colorForElement:@"HNJobs"];
            [self insertSubview:jobsView atIndex:0];
            self.scoreLabel.text = @"HN Jobs";
            self.postedTimeLabel.text = @"";
            self.commentBGButton.hidden = YES;
            self.commentTagButton.hidden = YES;
            self.commentsLabel.hidden = YES;
            self.bottomBar.backgroundColor = [HNTheme colorForElement:@"HNJobsBottom"];
        }
        
        // Mark as Read
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"MarkAsRead"]) {
            if ([[HNManager sharedManager] hasUserReadPost:post]) {
                self.titleLabel.alpha = 0.35;
            }
        }
    }
    
    return self;
}


@end
