//
//  HNSingleton.h
//  HackerNews
//
//  Created by Ben Gordon on 1/19/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNSingleton : NSObject {
}

@property (nonatomic, retain) NSMutableDictionary *themeDict;

+(HNSingleton*)sharedHNSingleton;
-(void)changeTheme;

@end
