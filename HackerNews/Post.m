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

@end
