//
//  Helpers.h
//  RedCup4
//
//  Created by Ben Gordon on 4/2/13.
//  Copyright (c) 2013 Ben Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comment.h"

// This color is used in LinkButton
#define kOrangeColor [UIColor colorWithRed:200/255.0f green:97/255.0f blue:41/255.0f alpha:1.0f]

@interface Helpers : NSObject

+(void)makeShadowForView:(UIView *)s withRadius:(float)radius;
+(NSString *)postStringFromDate:(NSDate *)date;
+(NSDate *)postDateFromString:(NSString *)string;
+(NSString *)timeAgoStringForDate:(NSDate *)date;

@end
