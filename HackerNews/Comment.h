//
//  Comment.h
//  HackerNews
//
//  Created by Benjamin Gordon on 5/1/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum CommentType {
    CommentTypeOpen = 0,
    CommentTypeClickClosed,
    CommentTypeHidden
} CommentType;

@interface Comment : NSObject

@property (nonatomic, retain) NSString *Text;
@property (nonatomic, retain) NSMutableAttributedString *attrText;
@property (nonatomic, retain) NSString *Username;
@property (nonatomic, retain) NSString *CommentID;
@property (nonatomic, retain) NSString *ParentID;
@property (nonatomic, assign) int Level;
@property (nonatomic, retain) NSDate *TimeCreated;
@property (nonatomic, retain) NSMutableArray *Children;
@property (nonatomic, retain) NSMutableArray *Links;
@property (nonatomic, assign) CommentType CellType;

+(Comment *)commentFromDictionary:(NSDictionary *)dict;
+(NSArray *)organizeComments:(NSArray *)comments topLevelID:(NSString *)topLevelID;

@end
