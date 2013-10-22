//
//  HNPost.h
//  libHN-Demo
//
//  Created by Ben Gordon on 10/6/13.
//  Copyright (c) 2013 subvertapps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PostType) {
    PostTypeDefault,
    PostTypeAskHN,
    PostTypeJobs
};

@interface HNPost : NSObject

#pragma mark - Properties
@property (nonatomic, assign) PostType Type;
@property (nonatomic,retain) NSString *Username;
@property (nonatomic, retain) NSString *UrlString;
@property (nonatomic, retain) NSString *UrlDomain;
@property (nonatomic, retain) NSString *Title;
@property (nonatomic, assign) int Points;
@property (nonatomic, assign) int CommentCount;
@property (nonatomic, retain) NSString *PostId;
@property (nonatomic, retain) NSString *TimeCreatedString;

#pragma mark - Methods
+ (NSArray *)parsedPostsFromHTML:(NSString *)html FNID:(NSString **)fnid;

@end
