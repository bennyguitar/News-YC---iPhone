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
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ssZ"];
    return [format stringFromDate:date];
}

+(NSDate *)postDateFromString:(NSString *)string {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    string = [string stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ssZ"];
    return [format dateFromString:string];
}


+(NSString *)timeAgoStringForDate:(NSDate *)date {
    NSTimeZone *currentTimeZone = [NSTimeZone defaultTimeZone];
    NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    int currentGMTOffset = [currentTimeZone secondsFromGMTForDate:date];
    int gmtOffset = [utcTimeZone secondsFromGMTForDate:date];
    NSTimeInterval gmtInterval = currentGMTOffset - gmtOffset;
    NSDate *localDate = [[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:date];
    
    
    
    // Now calculate how long ago it was.
    NSTimeInterval interval = [localDate timeIntervalSinceNow];
    interval = abs(interval);
    
    NSString *plural = @"";
    
    if (interval < 60) {
        if ((int)interval > 1) {
            plural = @"s";
        }
        return [NSString stringWithFormat:@"%d second%@ ago", (int)interval, plural];
    }
    else if (interval < 3600) {
        if ((int)interval/60 > 1) {
            plural = @"s";
        }
        return [NSString stringWithFormat:@"%d minute%@ ago", (int)interval/60, plural];
    }
    else if (interval < 86400) {
        if ((int)interval/3600 > 1) {
            plural = @"s";
        }
        return [NSString stringWithFormat:@"%d hour%@ ago", (int)interval/3600, plural];
    }
    
    if ((int)interval/86400 > 1) {
        plural = @"s";
    }
    return [NSString stringWithFormat:@"%d day%@ ago", (int)interval/86400, plural];
}

@end
