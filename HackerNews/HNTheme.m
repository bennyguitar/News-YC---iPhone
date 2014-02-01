//
//  HNSingleton.m
//  HackerNews
//
//  Created by Ben Gordon on 1/19/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "HNTheme.h"
#import "Helpers.h"

@implementation HNTheme

static HNTheme * _currentTheme = nil;

+(HNTheme*)currentTheme;
{
	@synchronized([HNTheme class])
	{
		if (!_currentTheme)
            _currentTheme  = [[HNTheme alloc]init];
		
		return _currentTheme;
	}
	
	return nil;
}



+(id)alloc
{
	@synchronized([HNTheme class])
	{
		NSAssert(_currentTheme == nil, @"Attempted to allocate a second instance of a singleton.");
		_currentTheme = [super alloc];
		return _currentTheme;
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


+ (void)changeThemeToType:(HNThemeType)type {
    if (type == HNThemeTypeNight) {
        [[HNTheme currentTheme].themeDict setValue:[UIColor colorWithWhite:0.2 alpha:1.0] forKey:@"CellBG"];
        [[HNTheme currentTheme].themeDict setValue:[UIColor colorWithWhite:0.92 alpha:1.0] forKey:@"MainFont"];
        [[HNTheme currentTheme].themeDict setValue:[UIColor colorWithWhite:0.98 alpha:1.0] forKey:@"SubFont"];
        [[HNTheme currentTheme].themeDict setValue:[UIColor colorWithWhite:0.25 alpha:1.0] forKey:@"BottomBar"];
        [[HNTheme currentTheme].themeDict setValue:[UIColor colorWithWhite:0.45 alpha:1.0] forKey:@"Separator"];
        [[HNTheme currentTheme].themeDict setValue:[UIColor colorWithWhite:0.17 alpha:1.0] forKey:@"TableTriangle"];
        [[HNTheme currentTheme].themeDict setValue:[UIImage imageNamed:@"commentbubble-01.png"] forKey:@"CommentBubble"];
        [[HNTheme currentTheme].themeDict setValue:[UIColor colorWithRed:149/255.0 green:78/255.0 blue:48/255.0 alpha:1.0] forKey:@"ShowHN"];
        [[HNTheme currentTheme].themeDict setValue:[UIColor colorWithRed:116/255.0 green:61/255.0 blue:39/255.0 alpha:1.0] forKey:@"ShowHNBottom"];
        [[HNTheme currentTheme].themeDict setValue:[UIColor colorWithRed:60/255.0 green:120/255.0 blue:71/255.0 alpha:1.0] forKey:@"HNJobs"];
        [[HNTheme currentTheme].themeDict setValue:[UIColor colorWithRed:45/255.0 green:90/255.0 blue:55/255.0 alpha:1.0] forKey:@"HNJobsBottom"];
        [[HNTheme currentTheme].themeDict setValue:[UIColor colorWithRed:44/255.0 green:44/255.0 blue:44/255.0 alpha:1.0] forKey:@"PostActions"];
        [[HNTheme currentTheme].themeDict setValue:kOrangeColor forKey:@"NavBar"];
    }
    else {
        [[HNTheme currentTheme].themeDict setValue:[UIColor colorWithWhite:0.85 alpha:1.0] forKey:@"CellBG"];
        [[HNTheme currentTheme].themeDict setValue:[UIColor colorWithWhite:0.4 alpha:1.0] forKey:@"MainFont"];
        [[HNTheme currentTheme].themeDict setValue:[UIColor colorWithWhite:0.20 alpha:1.0] forKey:@"SubFont"];
        [[HNTheme currentTheme].themeDict setValue:[UIColor colorWithWhite:0.75 alpha:1.0] forKey:@"BottomBar"];
        [[HNTheme currentTheme].themeDict setValue:[UIColor colorWithWhite:0.5 alpha:1.0] forKey:@"Separator"];
        [[HNTheme currentTheme].themeDict setValue:[UIColor colorWithWhite:0.89 alpha:1.0] forKey:@"TableTriangle"];
        [[HNTheme currentTheme].themeDict setValue:[UIImage imageNamed:@"commentbubbleDark.png"] forKey:@"CommentBubble"];
        [[HNTheme currentTheme].themeDict setValue:[UIColor colorWithRed:252/255.0 green:163/255.0 blue:131/255.0 alpha:1.0] forKey:@"ShowHN"];
        [[HNTheme currentTheme].themeDict setValue:[UIColor colorWithRed:205/255.0 green:133/255.0 blue:109/255.0 alpha:1.0] forKey:@"ShowHNBottom"];
        [[HNTheme currentTheme].themeDict setValue:[UIColor colorWithRed:170/255.0 green:235/255.0 blue:185/255.0 alpha:1.0] forKey:@"HNJobs"];
        [[HNTheme currentTheme].themeDict setValue:[UIColor colorWithRed:128/255.0 green:178/255.0 blue:141/255.0 alpha:1.0] forKey:@"HNJobsBottom"];
        [[HNTheme currentTheme].themeDict setValue:[UIColor colorWithRed:144/255.0 green:144/255.0 blue:144/255.0 alpha:1.0] forKey:@"PostActions"];
        [[HNTheme currentTheme].themeDict setValue:kOrangeColor forKey:@"NavBar"];
    }
}

+ (UIColor *)colorForElement:(NSString *)name {
    return [HNTheme currentTheme].themeDict[name] ? [HNTheme currentTheme].themeDict[name]
    : [UIColor clearColor];
}

+ (UIImage *)imageForKey:(NSString *)name {
    return [HNTheme currentTheme].themeDict[name] ? [HNTheme currentTheme].themeDict[name]
    : nil;
}

@end
