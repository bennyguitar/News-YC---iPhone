//
//  Post.m
//  HackerNews
//
//  Created by Benjamin Gordon on 5/1/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "Post.h"
#import "Helpers.h"

@implementation Post

+(Post *)postFromDictionary:(NSDictionary *)dict {
    Post *newPost = [[Post alloc] init];
    
    newPost.Username = [dict objectForKey:@"username"];
    newPost.PostID = [dict objectForKey:@"_id"];
    newPost.URLString = [dict objectForKey:@"url"];
    newPost.Points = [[dict objectForKey:@"points"] intValue];
    newPost.CommentCount = [[dict objectForKey:@"num_comments"] intValue];
    newPost.Title = [dict objectForKey:@"title"];
    newPost.HasRead = NO;
    newPost.TimeCreated = [Helpers postDateFromString:[dict objectForKey:@"create_ts"]];
    
    return newPost;
}

@end
