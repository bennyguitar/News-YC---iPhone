//
//  HNPostURL.h
//  HackerNews
//
//  Created by Daniel Rosado on 09/11/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNPostURL : NSURL

- (id)initWithString:(NSString *)URLString andMobileFriendlyString:(NSString*)mFriendlyURLString;

@property (nonatomic, readonly, strong) NSString *mobileFriendlyAbsoluteString;
@property (nonatomic, readonly, strong) NSURL *mobileFriendlyAbsoluteURL;

@end
