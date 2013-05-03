//
//  Helpers.h
//  RedCup4
//
//  Created by Ben Gordon on 4/2/13.
//  Copyright (c) 2013 Ben Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comment.h"

@interface Helpers : NSObject

+(void)makeShadowForView:(UIView *)s withRadius:(float)radius;
+(BOOL)isViewOnScreen:(UIView *)view;
+(NSString *)replaceHTMLMarks:(NSString *)text forComment:(Comment *)comment;

@end
