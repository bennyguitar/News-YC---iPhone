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

+(Comment *)commentFromDictionary:(NSDictionary *)dict {
    Comment *newComment = [[Comment alloc] init];
    
    newComment.Text = [Helpers replaceHTMLMarks:[dict objectForKey:@"text"]];
    newComment.CommentID = [dict objectForKey:@"_id"];
    newComment.ParentID = [dict objectForKey:@"parent_sigid"];
    newComment.Username = [dict objectForKey:@"username"];
    newComment.Level = 0;
    newComment.Children = [@[] mutableCopy];
    
    return newComment;
}

+(NSArray *)organizeComments:(NSMutableArray *)comments topLevelID:(NSString *)topLevelID {
    NSMutableArray *organizedComments = [@[] mutableCopy];
    NSMutableArray *topLevelComments = [@[] mutableCopy];
    
    // 1. Find all Top-Level comments
    int yy = comments.count;
    for (int xx = 0; xx < yy; xx++) {
        Comment *comment = comments[xx];
        if ([comment.ParentID isEqualToString:topLevelID]) {
            [topLevelComments addObject:comment];
            [comments removeObject:comment];
            yy--;
        }
    }
    
    // 2. Add Children to Top-Level
    for (Comment *comment in topLevelComments) {
        [Comment addChildrenToComment:comment fromPool:comments count:[NSNumber numberWithInt:comments.count]];
    }
    
    // 3. Get Levels and add to same-layer Array
    for (Comment *comment in topLevelComments) {
        [Comment addLevel:0 toComment:comment forArray:organizedComments];
    }
    
    return organizedComments;
}

+(void)addChildrenToComment:(Comment *)comment fromPool:(NSMutableArray *)pool count:(NSNumber *)count {
    for (int xx = 0; xx < [count intValue]; xx++) {
        Comment *poolComment = [pool objectAtIndex:xx];
        if ([poolComment.ParentID isEqualToString:comment.CommentID]) {
            [comment.Children addObject:poolComment];
            //[pool removeObject:poolComment];
            //count = [NSNumber numberWithInt:[count intValue] - 1];
            [Comment addChildrenToComment:poolComment fromPool:pool count:count];
        }
    }
}

+(void)addLevel:(int)level toComment:(Comment *)comment forArray:(NSMutableArray *)orderedArray {
    comment.Level = level;
    [orderedArray addObject:comment];
    for (Comment *childComment in comment.Children) {
        [Comment addLevel:level+1 toComment:childComment forArray:orderedArray];
    }
}

@end
