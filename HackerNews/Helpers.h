//
//  Helpers.h
//  RedCup4
//
//  Created by Ben Gordon on 4/2/13.
//  Copyright (c) 2013 Ben Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HNComment.h"

// This color is used in LinkButton
#define kOrangeColor [UIColor colorWithRed:255/255.0f green:99/255.0f blue:37/255.0f alpha:1.0f]

#define kHeaderImageHeight 44
#define kHeaderImageWidth 98

#define kProProductID @"com.subvertllc.HackerNews.Pro"

@interface Helpers : NSObject

+(void)makeShadowForView:(UIView *)s withRadius:(float)radius;
+(NSString *)postStringFromDate:(NSDate *)date;
+(NSDate *)postDateFromString:(NSString *)string;
+(NSString *)timeAgoStringForDate:(NSDate *)date;
+ (void)buildNavBarForController:(UINavigationController *)navController leftImage:(BOOL)leftImage;
+ (void)buildNavigationController:(UIViewController *)controller leftImage:(BOOL)leftImage rightImages:(NSArray *)rImages rightActions:(NSArray *)rActions;
+ (void)navigationController:(UIViewController *)controller addActivityIndicator:(UIActivityIndicatorView **)indicator;
+ (void)addUpvoteButtonToNavigationController:(UIViewController *)controller action:(SEL)action;

@end

@interface NavBarButtonItem : UIBarButtonItem
- (void)setFrameForHeight:(float)height;
@end
