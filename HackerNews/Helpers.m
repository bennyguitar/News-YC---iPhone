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

+(NSString *)replaceHTMLMarks:(NSString *)text forComment:(Comment *)comment {
    text = [text stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n\n"];
    text = [text stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"<i>" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"</i>" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"&#38;" withString:@"&"];
    text = [text stringByReplacingOccurrencesOfString:@"&#62;" withString:@">"];
    
    NSArray *linkTextComponents = [text componentsSeparatedByString:@"<a href=\""];
    NSString *newString = @"";
    for (int xx = 0; xx < linkTextComponents.count; xx++) {
        NSString *component = linkTextComponents[xx];
        if (xx == 0) {
            newString = component;
        }
        else {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ contains[c] SELF", component];
            if ([predicate evaluateWithObject:@"</a>"]) {
                // Contains a link
                NSScanner *scanner = [NSScanner scannerWithString:component];
                NSString *linkString=@"";
                [scanner scanUpToString:@"\" rel=" intoString:&linkString];
                [comment.Links addObject:linkString];
                newString = [newString stringByAppendingString:[NSString stringWithFormat:@" %@", linkString]];
                
                // Now grab the rest of the comment after the link
                // and add it back to newString
                NSArray *commentComponents = [component componentsSeparatedByString:@"</a>"];
                if (commentComponents.count > 1) {
                    newString = [newString stringByAppendingString:[NSString stringWithFormat:@" %@",commentComponents[1]]];
                }
            }
            else {
                // No Link
                newString = [newString stringByAppendingString:[NSString stringWithFormat:@" %@", component]];
            }
        }
    }
    
    return linkTextComponents.count > 0 ? newString : text;
}

+(NSString *)postStringFromDate:(NSDate *)date {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"YYYY-MM-dd'T'HH:mm:ssZ"];
    return [format stringFromDate:date];
}

+(NSDate *)postDateFromString:(NSString *)string {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"YYYY-MM-dd'T'HH:mm:ssZ"];
    return [format dateFromString:string];
}


@end
