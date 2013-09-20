//
//  Post.m
//  HackerNews
//
//  Created by Benjamin Gordon on 5/1/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "Post.h"
#import "Helpers.h"
#import "HNSingleton.h"

@implementation Post

+(Post *)postFromDictionary:(NSDictionary *)dict {
    Post *newPost = [[Post alloc] init];
    
    // Set Data
    newPost.Username = [dict objectForKey:@"username"];
    newPost.PostID = [dict objectForKey:@"_id"];
    newPost.hnPostID = [dict objectForKey:@"id"];
    newPost.Points = [[dict objectForKey:@"points"] intValue];
    newPost.CommentCount = [[dict objectForKey:@"num_comments"] intValue];
    newPost.Title = [dict objectForKey:@"title"];
    newPost.TimeCreated = [Helpers postDateFromString:[dict objectForKey:@"create_ts"]];
    newPost.isOpenForActions = NO;
    
    // Set URL for Ask HN
    if ([dict objectForKey:@"url"] == [NSNull null]) {
        newPost.URLString = [NSString stringWithFormat:@"http://news.ycombinator.com/item?id=%@", [dict objectForKey:@"id"]];
    }
    else {
        newPost.URLString = [dict objectForKey:@"url"];
    }
    
    // Mark as Read
    newPost.HasRead = [[HNSingleton sharedHNSingleton].hasReadThisArticleDict objectForKey:newPost.PostID] ? YES : NO;
    
    return newPost;
}

+(NSArray *)orderPosts:(NSMutableArray *)posts byItemIDs:(NSArray *)items {
    NSMutableArray *orderedPosts = [@[] mutableCopy];
    
    for (NSString *itemID in items) {
        for (Post *post in posts) {
            if ([post.PostID isEqualToString:itemID]) {
                [orderedPosts addObject:post];
                [posts removeObject:post];
                break;
            }
        }
    }
    
    return orderedPosts;
}

+ (NSArray *)parsedFrontPagePostsFromHTML:(NSString *)htmlString {
    // Set up
    NSArray *htmlComponents = [htmlString componentsSeparatedByString:@"<tr><td align=right valign=top class=\"title\">"];
    NSMutableArray *postArray = [NSMutableArray array];
    
    // Scan through components and build posts
    for (int xx = 1; xx < htmlComponents.count; xx++) {
        // Create new Post
        Post *newPost = [[Post alloc] init];
        
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
        
        // Scan URL
        [scanner scanUpToString:@"<a href=\"" intoString:&trash];
        [scanner scanString:@"<a href=\"" intoString:&trash];
        [scanner scanUpToString:@"\">" intoString:&urlString];
        if ([urlString rangeOfString:@"http"].location == NSNotFound) {
            urlString = [@"https://news.ycombinator.com/" stringByAppendingString:urlString];
        }
        newPost.URLString = urlString;
        
        // Scan Title
        [scanner scanString:@"\">" intoString:&trash];
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
        [scanner scanUpToString:@">" intoString:&trash];
        [scanner scanString:@">" intoString:&trash];
        [scanner scanUpToString:@"</a> " intoString:&author];
        newPost.Username = author;
        
        // Scan Time Ago
        [scanner scanString:@"</a> " intoString:&trash];
        [scanner scanUpToString:@"ago" intoString:&hoursAgo];
        hoursAgo = [hoursAgo stringByAppendingString:@"ago"];
        newPost.TimeCreatedString = hoursAgo;
        newPost.TimeCreated = nil;
        
        // Scan Number of Comments
        [scanner scanUpToString:@"<a href=\"item?id=" intoString:&trash];
        [scanner scanString:@"<a href=\"item?id=" intoString:&trash];
        [scanner scanUpToString:@"\">" intoString:&postId];
        [scanner scanString:@"\">" intoString:&trash];
        [scanner scanUpToString:@"</a>" intoString:&comments];
        newPost.PostID = postId;
        newPost.hnPostID = postId;
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
        if ([newPost.PostID isEqualToString:@""] && newPost.Points == 0 && [hoursAgo isEqualToString:@"ago"]) {
            newPost.isJobPost = YES;
        }
        
        // Grab FNID if last
        if (xx == htmlComponents.count - 1) {
            [scanner scanUpToString:@"<td class=\"title\"><a href=\"" intoString:&trash];
            NSString *fnid = @"";
            [scanner scanString:@"<td class=\"title\"><a href=\"" intoString:&trash];
            [scanner scanUpToString:@"\"" intoString:&fnid];
            [HNSingleton sharedHNSingleton].CurrentFNID = fnid;
        }
        
        [postArray addObject:newPost];
    }
    
    return postArray;
}


@end
