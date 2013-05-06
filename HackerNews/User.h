//
//  User.h
//  HackerNews
//
//  Created by Benjamin Gordon on 5/5/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, retain) NSString *Username;
@property (nonatomic, assign) int Karma;
@property (nonatomic, assign) int Age;
@property (nonatomic, retain) NSString *AboutInfo;


@end
