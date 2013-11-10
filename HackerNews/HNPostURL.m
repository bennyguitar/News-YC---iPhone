//
//  HNPostURL.m
//  HackerNews
//
//  Created by Daniel Rosado on 09/11/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "HNPostURL.h"

@interface HNPostURL ()

@property (nonatomic, readwrite, strong) NSString *mobileFriendlyAbsoluteString;
@property (nonatomic, readwrite, strong) NSURL *mobileFriendlyAbsoluteURL;

@end


@implementation HNPostURL

#pragma mark - Designated initializer
- (id)initWithString:(NSString *)URLString andMobileFriendlyString:(NSString*)mFriendlyURLString
{
    self = [super initWithString:URLString];
    if (self) {
        _mobileFriendlyAbsoluteString = mFriendlyURLString;
        _mobileFriendlyAbsoluteURL = [[NSURL alloc] initWithString:mFriendlyURLString];
    }
    
    return  self;
}

#pragma mark - Mobile friendly getters
- (NSString*)mobileFriendlyAbsoluteString
{
    return _mobileFriendlyAbsoluteString;
}

- (NSURL*)mobileFriendlyAbsoluteURL
{
    return _mobileFriendlyAbsoluteURL;
}

@end
