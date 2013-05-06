//
//  HNSingleton.h
//  HackerNews
//
//  Created by Ben Gordon on 1/19/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"

enum fType {
    fTypeTop = 0,
    fTypeNew = 1,
    fTypeAsk = 2
};

enum sDirection {
    scrollDirectionUp = 0,
    scrollDirectionDown = 1,
};

enum theme {
    themeNight = 0,
    themeDay = 1
};

@interface HNSingleton : NSObject {
}

@property (nonatomic, retain) NSMutableDictionary *hasReadThisArticleDict;
@property (nonatomic, retain) NSMutableDictionary *themeDict;
@property (nonatomic, assign) enum fType filter;
@property (nonatomic, retain) NSString *SessionCookie;

+(HNSingleton*)sharedHNSingleton;
-(void)changeTheme;

@end
