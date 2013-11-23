//
//  HNSingleton.h
//  HackerNews
//
//  Created by Ben Gordon on 1/19/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HNThemeType) {
    HNThemeTypeNight,
    HNThemeTypeDay
};

@interface HNTheme : NSObject {
}

@property (nonatomic, retain) NSMutableDictionary *themeDict;

+ (HNTheme*)currentTheme;
+ (void)changeThemeToType:(HNThemeType)type;
+ (UIColor *)colorForElement:(NSString *)name;
+ (UIImage *)imageForKey:(NSString *)name;

@end
