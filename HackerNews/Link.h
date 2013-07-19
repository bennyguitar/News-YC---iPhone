//
//  Link.h
//  HackerNews
//
//  Created by Benjamin Gordon on 7/17/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Link : NSObject

@property (nonatomic, retain) NSURL *URL;
@property (nonatomic, assign) NSRange URLRange;


@end
