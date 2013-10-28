//
//  HNComment.m
//  libHN-Demo
//
//  Created by Ben Gordon on 10/6/13.
//  Copyright (c) 2013 subvertapps. All rights reserved.
//

#import "HNComment.h"
#import "HNCommentLink.h"
#import "HNUtilities.h"

@implementation HNComment

#pragma mark - Parse Comments
+ (NSArray *)parsedCommentsFromHTML:(NSString *)html forPost:(HNPost *)post {
    // Set Up
    NSMutableArray *comments = [@[] mutableCopy];
    NSString *trash = @"";
    NSArray *htmlComponents = [html componentsSeparatedByString:@"<tr><td><table border=0><tr><td><img src=\"s.gif\""];
    
    if (post.Type == PostTypeAskHN) {
        // Grab AskHN Post
        NSScanner *scanner = [NSScanner scannerWithString:htmlComponents[0]];
        NSString *trash = @"", *text = @"", *user = @"", *timeAgo = @"", *commentId = @"", *upvoteUrl = @"";
        
        // Check for Upvote
        if ([htmlComponents[0] rangeOfString:@"dir=up"].location != NSNotFound) {
            [scanner scanUpToString:@"vote(this)\" href=\"" intoString:&trash];
            [scanner scanString:@"vote(this)\" href=\"" intoString:&trash];
            [scanner scanUpToString:@"whence" intoString:&upvoteUrl];
            upvoteUrl = [upvoteUrl stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        }
        
        // Get Id
        [scanner scanUpToString:@"<span id=down_" intoString:&trash];
        [scanner scanString:@"<span id=down_" intoString:&trash];
        [scanner scanUpToString:@">" intoString:&commentId];
        
        // Get User
        [scanner scanUpToString:@"by <a href=\"user?id=" intoString:&trash];
        [scanner scanString:@"by <a href=\"user?id=" intoString:&trash];
        [scanner scanUpToString:@"\">" intoString:&user];
        
        // Get Time Created String
        [scanner scanUpToString:@"</a> " intoString:&trash];
        [scanner scanString:@"</a> " intoString:&trash];
        [scanner scanUpToString:@"ago" intoString:&timeAgo];
        timeAgo = [timeAgo stringByAppendingString:@"ago"];
        
        // Get Text
        [scanner scanUpToString:@"</tr><tr><td></td><td>" intoString:&trash];
        [scanner scanString:@"</tr><tr><td></td><td>" intoString:&trash];
        [scanner scanUpToString:@"</td>" intoString:&text];
        
        // Get rid of special text crap
        if ([text rangeOfString:@"<form method=post"].location != NSNotFound) {
            text = @"";
        }
        
        // Create special comment for it
        HNComment *newComment = [[HNComment alloc] init];
        newComment.Level = 0;
        newComment.Username = user;
        newComment.TimeCreatedString = timeAgo;
        newComment.Text = [HNUtilities stringByReplacingHTMLEntitiesInText:text];
        newComment.Links = [HNCommentLink linksFromCommentText:newComment.Text];
        newComment.Type = CommentTypeAskHN;
        newComment.UpvoteURLAddition = upvoteUrl.length>0 ? upvoteUrl : nil;
        newComment.CommentId = commentId;
        [comments addObject:newComment];
    }
    
    if (post.Type == PostTypeJobs) {
        // Grab Jobs Post
        NSScanner *scanner = [NSScanner scannerWithString:htmlComponents[0]];
        NSString *trash = @"", *text = @"";
        [scanner scanUpToString:@"</tr><tr><td></td><td>" intoString:&trash];
        [scanner scanString:@"</tr><tr><td></td><td>" intoString:&trash];
        [scanner scanUpToString:@"</td>" intoString:&text];
        
        // Create special comment for it
        HNComment *newComment = [[HNComment alloc] init];
        newComment.Level = 0;
        newComment.Text = [HNUtilities stringByReplacingHTMLEntitiesInText:text];
        newComment.Links = [HNCommentLink linksFromCommentText:newComment.Text];
        newComment.Type = CommentTypeJobs;
        [comments addObject:newComment];
    }
    
    for (int xx = 1; xx < htmlComponents.count; xx++) {
        NSScanner *scanner = [NSScanner scannerWithString:htmlComponents[xx]];
        HNComment *newComment = [[HNComment alloc] init];
        NSString *level = @"";
        NSString *user = @"";
        NSString *text = @"";
        NSString *timeAgo = @"";
        NSString *reply = @"";
        NSString *commentId = @"";
        NSString *upvoteString = @"";
        NSString *downvoteString = @"";
        
        
        
        // Get Comment Level
        [scanner scanString:@"height=1 width=" intoString:&trash];
        [scanner scanUpToString:@">" intoString:&level];
        newComment.Level = [level intValue] / 40;
        
        // If Logged In - Grab Voting Strings
        if ([htmlComponents[xx] rangeOfString:@"dir=up"].location != NSNotFound) {
            // Scan Upvote String
            [scanner scanUpToString:@"href=\"" intoString:&trash];
            [scanner scanString:@"href=\"" intoString:&trash];
            [scanner scanUpToString:@"whence" intoString:&upvoteString];
            newComment.UpvoteURLAddition = [upvoteString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
            
            // Check for downvote String
            if ([htmlComponents[xx] rangeOfString:@"dir=down"].location != NSNotFound) {
                [scanner scanUpToString:@"href=\"" intoString:&trash];
                [scanner scanString:@"href=\"" intoString:&trash];
                [scanner scanUpToString:@"whence" intoString:&downvoteString];
                newComment.DownvoteURLAddition = [downvoteString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
            }
        }
        
        // Get Username
        [scanner scanUpToString:@"<a href=\"user?id=" intoString:&trash];
        [scanner scanString:@"<a href=\"user?id=" intoString:&trash];
        [scanner scanUpToString:@"\">" intoString:&user];
        newComment.Username = user.length > 0 ? user : @"[deleted]";
        
        // Get Date/Time Label
        [scanner scanUpToString:@"</a> " intoString:&trash];
        [scanner scanString:@"</a> " intoString:&trash];
        [scanner scanUpToString:@" |" intoString:&timeAgo];
        newComment.TimeCreatedString = timeAgo;
        
        // Get Comment Text
        [scanner scanUpToString:@"<font color=" intoString:&trash];
        [scanner scanString:@"<font color=" intoString:&trash];
        [scanner scanUpToString:@">" intoString:&trash];
        [scanner scanString:@">" intoString:&trash];
        [scanner scanUpToString:@"</font>" intoString:&text];
        newComment.Text = [HNUtilities stringByReplacingHTMLEntitiesInText:text];
        
        // Get CommentId
        [scanner scanUpToString:@"reply?id=" intoString:&trash];
        [scanner scanString:@"reply?id=" intoString:&trash];
        [scanner scanUpToString:@"&" intoString:&commentId];
        newComment.CommentId = commentId;
        
        // Get Reply URL Addition
        [scanner scanUpToString:@"<font size=1><u><a href=\"" intoString:&trash];
        [scanner scanString:@"<font size=1><u><a href=\"" intoString:&trash];
        [scanner scanUpToString:@"\">reply" intoString:&reply];
        newComment.ReplyURLString = reply;
        
        // Get Links
        newComment.Links = [HNCommentLink linksFromCommentText:newComment.Text];
        
        // Save Comment
        [comments addObject:newComment];
    }
    
    return comments;
}

@end
