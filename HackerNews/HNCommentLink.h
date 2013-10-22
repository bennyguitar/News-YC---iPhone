//
//  HNCommentLink.h
//  libHN-Demo
//
//  Created by Ben Gordon on 10/6/13.
//  Copyright (c) 2013 subvertapps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNCommentLink : NSObject

typedef NS_ENUM(NSInteger, LinkType) {
    LinkTypeDefault,
    LinkTypeHN
};

#pragma mark - Properties
@property (nonatomic, retain) NSURL *Url;
@property (nonatomic, assign) NSRange UrlRange;
@property (nonatomic, assign) LinkType Type;


#pragma mark - Methods
+ (NSArray *)linksFromCommentText:(NSString *)commentText;

@end
