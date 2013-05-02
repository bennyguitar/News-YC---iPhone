//
//  Comment.h
//  HackerNews
//
//  Created by Benjamin Gordon on 5/1/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject

@property (nonatomic, retain) NSString *Text;
@property (nonatomic, retain) NSString *Username;
@property (nonatomic, retain) NSString *CommentID;
@property (nonatomic, retain) NSString *ParentID;
@property (nonatomic, assign) int Level;
@property (nonatomic, retain) NSMutableArray *Children;

+(Comment *)commentFromDictionary:(NSDictionary *)dict;
+(NSArray *)organizeComments:(NSArray *)comments topLevelID:(NSString *)topLevelID;

@end
