//
//  Helpers.m
//  RedCup4
//
//  Created by Ben Gordon on 4/2/13.
//  Copyright (c) 2013 Ben Gordon. All rights reserved.
//

#import "Helpers.h"
#import <QuartzCore/QuartzCore.h>

@implementation Helpers

+(void)makeShadowForView:(UIView *)s withRadius:(float)radius {
    s.layer.shadowColor = [UIColor blackColor].CGColor;
    s.layer.shadowOpacity = 0.4f;
    s.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    s.layer.shadowRadius = 3.0f;
    s.layer.masksToBounds = NO;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:s.bounds cornerRadius:radius];
    s.layer.shadowPath = path.CGPath;
}


+(BOOL)isViewOnScreen:(UIView *)view {
    if ([view superview]==nil) {
        return NO;
    }
    if (view.frame.origin.x < [UIScreen mainScreen].bounds.size.width && view.frame.origin.x >= 0) {
        return YES;
    }
    if (view.frame.origin.y < [UIScreen mainScreen].bounds.size.height && view.frame.origin.y >= 0) {
        return YES;
    }
    
    return NO;
}



@end
