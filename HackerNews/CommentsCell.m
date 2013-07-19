//
//  CommentsCell.m
//  HackerNews
//
//  Created by Benjamin Gordon on 11/7/12.
//  Copyright (c) 2012 Benjamin Gordon. All rights reserved.
//

#import "CommentsCell.h"
#import <QuartzCore/QuartzCore.h>

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
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(CommentsCell *)cellForComment:(Comment *)newComment atIndex:(NSIndexPath *)indexPath fromController:(UIViewController *)controller {
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    
    // Color cell elements
    self.comment.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"MainFont"];
    self.username.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"SubFont"];
    self.postedTime.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"SubFont"];
    self.topBar.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"BottomBar"];
    
    if (newComment) {
        // Set Data to UI Elements
        self.commentLevel = newComment.Level;
        self.holdingView.frame = CGRectMake(15 * newComment.Level, 0, self.frame.size.width - (15*newComment.Level), self.frame.size.height);
        self.username.text = newComment.Username;
        self.postedTime.text = newComment.TimeAgoString;
        
        // Set Border based on CellType
        if (newComment.CellType == CommentTypeClickClosed) {
            self.topBarBorder.alpha = 1;
        }
        else if (newComment.CellType == CommentTypeHidden) {
            self.topBarBorder.alpha = 0;
        }
        else if (newComment.CellType == CommentTypeOpen) {
            self.topBarBorder.alpha = 0;
            self.comment.attributedText = newComment.attrText;
            
            // Set size of Comment Label
            CGSize s = [self.comment.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(self.comment.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
            self.comment.frame = CGRectMake(self.comment.frame.origin.x, self.comment.frame.origin.y, self.comment.frame.size.width, s.height);
            self.comment.numberOfLines = 0;
            
            /*
            // Add Links
            for (int xx = 0; xx < newComment.Links.count; xx++) {
                LinkButton *newLinkButton = [LinkButton newLinkButtonWithTag:indexPath.row linkTag:xx frame:CGRectMake(15*newComment.Level + kPad, self.comment.frame.size.height + self.comment.frame.origin.y + xx*kPad + xx*30 + kPad, self.frame.size.width - (15*newComment.Level + 2*kPad), 30) title:newComment.Links[xx]];
                [newLinkButton addTarget:controller action:@selector(didClickExternalLinkInComment:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:newLinkButton];
            }
             */
        }
        
        // Set action of topBarButton
        self.topBarButton.tag = indexPath.row;
        [self.topBarButton addTarget:controller action:@selector(hideNestedCommentsCell:) forControlEvents:UIControlEventTouchDownRepeat];
    }
    else {
        // No comments
        self.username.text = @"";
        self.postedTime.text = @"";
        self.comment.text = @"Ahh! Looks like no comments exist!";
        self.comment.textAlignment = NSTextAlignmentCenter;
    }
    
    return self;
}

-(float)heightForComment:(Comment *)newComment {
    if (newComment) {
        // Comment is Open
        if (newComment.CellType == CommentTypeOpen) {
            CGSize s = [newComment.Text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(self.comment.frame.size.width - (newComment.Level*15), MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
            return s.height + 45/* + (newComment.Links.count*30 + newComment.Links.count*kPad)*/;
        }
        
        // Comment has been Clicked Closed by User
        else if (newComment.CellType == CommentTypeClickClosed) {
            return kCommentsHidden;
        }
        
        else if (newComment.CellType == CommentTypeHidden) {
            return 0;
        }
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

@end
