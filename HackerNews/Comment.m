//
//  Comment.m
//  HackerNews
//
//  Created by Benjamin Gordon on 5/1/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "Comment.h"
#import "Helpers.h"

@implementation Comment

-(id)init {
    self = [super init];
    if (self) {
        self.Children = [@[] mutableCopy];
        self.Links = [@[] mutableCopy];
        self.Text = @"";
        self.Username = @"";
        self.CommentID = @"";
        self.ParentID = @"";
        self.Level = 0;
        self.TimeCreated = [NSDate date];
        self.CellType = CommentTypeOpen;
    }
    return self;
}

+(Comment *)commentFromDictionary:(NSDictionary *)dict {
    Comment *newComment = [[Comment alloc] init];
    
    if ([dict objectForKey:@"text"] != [NSNull null]) {
        newComment.Text = [Helpers replaceHTMLMarks:[dict objectForKey:@"text"] forComment:newComment];
    }
    
    newComment.CommentID = [dict objectForKey:@"_id"];
    newComment.ParentID = [dict objectForKey:@"parent_sigid"];
    newComment.Username = [dict objectForKey:@"username"];
    newComment.Level = 0;
    newComment.TimeCreated = [Helpers postDateFromString:[dict objectForKey:@"create_ts"]];
    
    return newComment;
}

+(NSArray *)organizeComments:(NSMutableArray *)comments topLevelID:(NSString *)topLevelID {
    NSMutableArray *organizedComments = [@[] mutableCopy];
    NSMutableArray *topLevelComments = [@[] mutableCopy];
    
    // 1. Find all Top-Level comments
    for (Comment *comment in comments) {
        if ([comment.ParentID isEqualToString:topLevelID]) {
            [topLevelComments addObject:comment];
        }
    }
    
    // 2. Add Children to Top-Level
    for (Comment *comment in topLevelComments) {
        [Comment addChildrenToComment:comment fromPool:comments];
    }
    
    // 3. Get Levels and add to a single layer Array
    for (Comment *comment in topLevelComments) {
        [Comment addLevel:0 toComment:comment forArray:organizedComments];
    }
    
    return organizedComments;
}

// Recursively adds Children comments to original Comment
// passed in from the pool of comments.
+(void)addChildrenToComment:(Comment *)comment fromPool:(NSMutableArray *)pool {
    for (Comment *poolComment in pool) {
        if ([poolComment.ParentID isEqualToString:comment.CommentID]) {
            [comment.Children addObject:poolComment];
            [Comment addChildrenToComment:poolComment fromPool:pool];
        }
    }
}

// Recursively changes the linked-list of comments
// into a single-layer array, and keeps the order so nested
// comments look good (Level property)
+(void)addLevel:(int)level toComment:(Comment *)comment forArray:(NSMutableArray *)orderedArray {
    comment.Level = level;
    [orderedArray addObject:comment];
    for (Comment *childComment in comment.Children) {
        [Comment addLevel:level+1 toComment:childComment forArray:orderedArray];
    }
}

@end
