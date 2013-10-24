//
//  HNComment.h
//  libHN-Demo
//
//  Created by Ben Gordon on 10/6/13.
//  Copyright (c) 2013 subvertapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HNPost.h"

typedef NS_ENUM(NSInteger, CommentType) {
    CommentTypeDefault,
    CommentTypeAskHN,
    CommentTypeJobs
};

@interface HNComment : NSObject

#pragma mark - Properties
@property (nonatomic, assign) CommentType Type;
@property (nonatomic, retain) NSString *Text;
@property (nonatomic, retain) NSString *Username;
@property (nonatomic, retain) NSString *CommentId;
@property (nonatomic, retain) NSString *ParentID;
@property (nonatomic, retain) NSString *TimeCreatedString;
@property (nonatomic, retain) NSString *ReplyURLString;
@property (nonatomic, assign) int Level;
@property (nonatomic, retain) NSArray *Links;
@property (nonatomic, retain) NSString *UpvoteURLAddition;
@property (nonatomic, retain) NSString *DownvoteURLAddition;

#pragma mark - Methods
+ (NSArray *)parsedCommentsFromHTML:(NSString *)html forPost:(HNPost *)post;


@end
