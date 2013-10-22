//
//  HNSingleton.h
//  HackerNews
//
//  Created by Ben Gordon on 1/19/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "IIViewDeckController.h"
#import "SubmitLinkViewController.h"
#import "KGStatusBar.h"

// libHN
#import "libHN.h"

// This determines whether logging in is allowed or not
#define kProfile NO

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

@property (nonatomic, retain) NSMutableDictionary *themeDict;

+(HNSingleton*)sharedHNSingleton;
-(void)changeTheme;

@end
