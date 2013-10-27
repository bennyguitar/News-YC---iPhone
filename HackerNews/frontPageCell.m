//
//  frontPageCell.m
//  HackerNews
//
//  Created by Benjamin Gordon on 11/6/12.
//  Copyright (c) 2012 Benjamin Gordon. All rights reserved.
//

#import "frontPageCell.h"
#import <QuartzCore/QuartzCore.h>
#import "HNSingleton.h"
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
    [super setSelected:selected animated:YES];
    if (selected) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = kOrangeColor;
        [self setSelectedBackgroundView:view];
    }
    else {
        self.backgroundColor = [UIColor clearColor];
    }
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
        self.titleLabel.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"MainFont"];
        self.postedTimeLabel.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"SubFont"];
        self.scoreLabel.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"SubFont"];
        self.bottomBar.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"BottomBar"];
        [self.commentTagButton setImage:[[HNSingleton sharedHNSingleton].themeDict objectForKey:@"CommentBubble"] forState:UIControlStateNormal];
        
        // Show HN Color
        if (self.titleLabel.text.length >= 9) {
            if ([[self.titleLabel.text substringWithRange:NSMakeRange(0, 9)] isEqualToString:@"Show HN: "]) {
                UIView *showHNView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
                showHNView.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"ShowHN"];
                self.bottomBar.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"ShowHNBottom"];
                [self insertSubview:showHNView atIndex:0];
            }
        }
        
        // Jobs Color
        if (post.Type == PostTypeJobs) {
            UIView *jobsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            jobsView.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"HNJobs"];
            [self insertSubview:jobsView atIndex:0];
            self.scoreLabel.text = @"HN Jobs";
            self.postedTimeLabel.text = @"";
            self.commentBGButton.hidden = YES;
            self.commentTagButton.hidden = YES;
            self.commentsLabel.hidden = YES;
            self.bottomBar.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"HNJobsBottom"];
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
