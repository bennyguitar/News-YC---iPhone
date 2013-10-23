//
//  HNSingleton.m
//  HackerNews
//
//  Created by Ben Gordon on 1/19/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "HNSingleton.h"
#import "AppDelegate.h"

@implementation HNSingleton

static HNSingleton * _sharedHNSingleton = nil;

+(HNSingleton*)sharedHNSingleton;
{
	@synchronized([HNSingleton class])
	{
		if (!_sharedHNSingleton)
            _sharedHNSingleton  = [[HNSingleton alloc]init];
		
		return _sharedHNSingleton;
	}
	
	return nil;
}



+(id)alloc
{
	@synchronized([HNSingleton class])
	{
		NSAssert(_sharedHNSingleton == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedHNSingleton = [super alloc];
		return _sharedHNSingleton;
	}
	
	return nil;
}




-(id)init {
	self = [super init];
	if (self != nil) {
        self.themeDict = [@{} mutableCopy];
	}
	
	return self;
}


-(void)changeTheme {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"NightMode"]) {
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.2 alpha:1.0] forKey:@"CellBG"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.92 alpha:1.0] forKey:@"MainFont"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.98 alpha:1.0] forKey:@"SubFont"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.25 alpha:1.0] forKey:@"BottomBar"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.45 alpha:1.0] forKey:@"Separator"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.17 alpha:1.0] forKey:@"TableTriangle"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIImage imageNamed:@"commentbubble-01.png"] forKey:@"CommentBubble"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithRed:149/255.0 green:78/255.0 blue:48/255.0 alpha:1.0] forKey:@"ShowHN"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithRed:116/255.0 green:61/255.0 blue:39/255.0 alpha:1.0] forKey:@"ShowHNBottom"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithRed:60/255.0 green:120/255.0 blue:71/255.0 alpha:1.0] forKey:@"HNJobs"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithRed:45/255.0 green:90/255.0 blue:55/255.0 alpha:1.0] forKey:@"HNJobsBottom"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithRed:44/255.0 green:44/255.0 blue:44/255.0 alpha:1.0] forKey:@"PostActions"];
    }
    else {
        NSLog(@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"Theme"]);
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.85 alpha:1.0] forKey:@"CellBG"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.4 alpha:1.0] forKey:@"MainFont"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.20 alpha:1.0] forKey:@"SubFont"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.75 alpha:1.0] forKey:@"BottomBar"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.5 alpha:1.0] forKey:@"Separator"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.89 alpha:1.0] forKey:@"TableTriangle"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIImage imageNamed:@"commentbubbleDark.png"] forKey:@"CommentBubble"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithRed:252/255.0 green:163/255.0 blue:131/255.0 alpha:1.0] forKey:@"ShowHN"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithRed:205/255.0 green:133/255.0 blue:109/255.0 alpha:1.0] forKey:@"ShowHNBottom"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithRed:170/255.0 green:235/255.0 blue:185/255.0 alpha:1.0] forKey:@"HNJobs"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithRed:128/255.0 green:178/255.0 blue:141/255.0 alpha:1.0] forKey:@"HNJobsBottom"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithRed:144/255.0 green:144/255.0 blue:144/255.0 alpha:1.0] forKey:@"PostActions"];
    }
}

@end
