//
//  HNPost.m
//  libHN-Demo
//
//  Created by Ben Gordon on 10/6/13.
//  Copyright (c) 2013 subvertapps. All rights reserved.
//

#import "HNPost.h"

@implementation HNPost

#pragma mark - Parse Posts
+ (NSArray *)parsedPostsFromHTML:(NSString *)html FNID:(NSString *__autoreleasing *)fnid {
    // Set up
    NSArray *htmlComponents = [html componentsSeparatedByString:@"<tr><td align=right valign=top class=\"title\">"];
    NSMutableArray *postArray = [NSMutableArray array];
    
    // Scan through components and build posts
    for (int xx = 1; xx < htmlComponents.count; xx++) {
        // If it's Dead - move past it
        if ([htmlComponents[xx] rangeOfString:@"<td class=\"title\"> [dead] <a"].location != NSNotFound) {
            continue;
        }
        
        // Create new Post
        HNPost *newPost = [[HNPost alloc] init];
        
        // Set Up for Scanning
        NSScanner *scanner = [[NSScanner alloc] initWithString:htmlComponents[xx]];
        NSString *trash = @"";
        NSString *urlString = @"";
        NSString *title = @"";
        NSString *hoursAgo = @"";
        NSString *comments = @"";
        NSString *author = @"";
        NSString *points = @"";
        NSString *postId = @"";
        NSString *upvoteString = @"";
        
        // Scan for Upvotes
        if ([htmlComponents[xx] rangeOfString:@"dir=up"].location != NSNotFound) {
            [scanner scanUpToString:@"href=\"" intoString:&trash];
            [scanner scanString:@"href=\"" intoString:&trash];
            [scanner scanUpToString:@"whence" intoString:&upvoteString];
            newPost.UpvoteURLAddition = upvoteString;
        }
        
        // Scan URL
        [scanner scanUpToString:@"<a href=\"" intoString:&trash];
        [scanner scanString:@"<a href=\"" intoString:&trash];
        [scanner scanUpToString:@"\"" intoString:&urlString];
        newPost.UrlString = urlString;
        
        // Scan Title
        [scanner scanUpToString:@">" intoString:&trash];
        [scanner scanString:@">" intoString:&trash];
        [scanner scanUpToString:@"</a>" intoString:&title];
        newPost.Title = title;
        
        // Scan Points
        [scanner scanUpToString:@"<span id=score_" intoString:&trash];
        [scanner scanUpToString:@">" intoString:&trash];
        [scanner scanString:@">" intoString:&trash];
        [scanner scanUpToString:@" point" intoString:&points];
        newPost.Points = [points intValue];
        
        // Scan Author
        [scanner scanUpToString:@"<a href=\"user?id=" intoString:&trash];
        [scanner scanString:@"<a href=\"user?id=" intoString:&trash];
        [scanner scanUpToString:@"\"" intoString:&author];
        newPost.Username = author;
        
        // Scan Time Ago
        [scanner scanUpToString:@"</a> " intoString:&trash];
        [scanner scanString:@"</a> " intoString:&trash];
        [scanner scanUpToString:@"ago" intoString:&hoursAgo];
        hoursAgo = [hoursAgo stringByAppendingString:@"ago"];
        newPost.TimeCreatedString = hoursAgo;
        
        // Scan Number of Comments
        [scanner scanUpToString:@"<a href=\"item?id=" intoString:&trash];
        [scanner scanString:@"<a href=\"item?id=" intoString:&trash];
        [scanner scanUpToString:@"\">" intoString:&postId];
        [scanner scanString:@"\">" intoString:&trash];
        [scanner scanUpToString:@"</a>" intoString:&comments];
        newPost.PostId = postId;
        if ([comments isEqualToString:@"discuss"]) {
            newPost.CommentCount = 0;
        }
        else {
            NSScanner *cScan = [[NSScanner alloc] initWithString:comments];
            NSString *cCount = @"";
            [cScan scanUpToString:@" " intoString:&cCount];
            newPost.CommentCount = [cCount intValue];
        }
        
        // Check if Jobs Post
        if (newPost.PostId.length == 0 && newPost.Points == 0 && [hoursAgo isEqualToString:@"ago"]) {
            newPost.Type = PostTypeJobs;
            if ([urlString rangeOfString:@"http"].location == NSNotFound) {
                newPost.PostId = [urlString stringByReplacingOccurrencesOfString:@"item?id=" withString:@""];
            }
        }
        else {
            // Check if AskHN
            if ([urlString rangeOfString:@"http"].location == NSNotFound && newPost.PostId.length > 0) {
                newPost.Type = PostTypeAskHN;
                urlString = [@"https://news.ycombinator.com/" stringByAppendingString:urlString];
            }
            else {
                newPost.Type = PostTypeDefault;
            }
        }

        
        // Grab FNID if last
        if (xx == htmlComponents.count - 1) {
            [scanner scanUpToString:@"<td class=\"title\"><a href=\"" intoString:&trash];
            NSString *Fnid = @"";
            [scanner scanString:@"<td class=\"title\"><a href=\"" intoString:&trash];
            [scanner scanUpToString:@"\"" intoString:&Fnid];
            *fnid = [Fnid stringByReplacingOccurrencesOfString:@"/" withString:@""];
        }
        
        [postArray addObject:newPost];
    }
    
    return postArray;
}

@end
