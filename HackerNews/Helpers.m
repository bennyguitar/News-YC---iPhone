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
    // Data object's TimeCreated property is in UTC
    // - Change it to local time
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

+ (void)buildNavBarForController:(UINavigationController *)navController {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [navController.navigationBar setBarTintColor:kOrangeColor];
    }
    else {
        [navController.navigationBar setTintColor:kOrangeColor];
    }
    
    UIImageView *mainImage = [[UIImageView alloc] initWithFrame:CGRectMake(navController.navigationBar.frame.size.width/2 - kHeaderImageWidth/2, navController.navigationBar.frame.size.height - kHeaderImageHeight, kHeaderImageWidth, kHeaderImageHeight)];
    mainImage.image = [UIImage imageNamed:@"header_img"];
    [navController.navigationBar addSubview:mainImage];
}

+ (void)navigationController:(UINavigationController *)navController addActivityIndicator:(UIActivityIndicatorView **)indicator {
    [*indicator setFrame:CGRectMake(navController.navigationBar.frame.size.width - 30, navController.navigationBar.frame.size.height/2 - 10, 20, 20)];
    [*indicator startAnimating];
    [*indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [navController.navigationBar addSubview:*indicator];
}

@end
