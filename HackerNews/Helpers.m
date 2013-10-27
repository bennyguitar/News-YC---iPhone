//
//  Helpers.m
//  RedCup4
//
//  Created by Ben Gordon on 4/2/13.
//  Copyright (c) 2013 Ben Gordon. All rights reserved.
//

#import "Helpers.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

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

+ (void)buildNavBarForController:(UINavigationController *)navController leftImage:(BOOL)leftImage {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [navController.navigationBar setBarTintColor:kOrangeColor];
    }
    else {
        [navController.navigationBar setTintColor:kOrangeColor];
    }
    
    // Add Center Image
    UIImageView *mainImage = [[UIImageView alloc] initWithFrame:CGRectMake(navController.navigationBar.frame.size.width/2 - kHeaderImageWidth/2, navController.navigationBar.frame.size.height - kHeaderImageHeight, kHeaderImageWidth, kHeaderImageHeight)];
    mainImage.image = [UIImage imageNamed:@"header_img"];
    [navController.navigationBar addSubview:mainImage];
    
    // Add Left Button
    if (leftImage) {
        AppDelegate *del = [[UIApplication sharedApplication] delegate];
        UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [leftButton setImage:[UIImage imageNamed:@"3bar-01"] forState:UIControlStateNormal];
        [leftButton addTarget:del.deckController action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
        [navController.navigationBar addSubview:leftButton];
    }
}

+ (void)buildNavigationController:(UIViewController *)controller leftImage:(BOOL)leftImage rightImages:(NSArray *)rImages rightActions:(NSArray *)rActions {
    // Change tint
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        controller.navigationController.navigationBar.barTintColor = kOrangeColor; /* iOS 7 */
        controller.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:0.0 alpha:0.6]; //For nav items
        controller.navigationController.navigationBar.translucent = NO;
    }
    else {
        [controller.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_background_ios6"] forBarMetrics:UIBarMetricsDefault];
        //controller.navigationController.navigationBar.tintColor = kOrangeColor; /* iOS 6 */
    }
    
    // Set Center Image
    for (UIView *subview in controller.navigationController.navigationBar.subviews) {
        if (subview.tag == 999) {
            [subview removeFromSuperview];
        }
    }
    UIImageView *mainImage = [[UIImageView alloc] initWithFrame:CGRectMake(controller.navigationController.navigationBar.frame.size.width/2 - kHeaderImageWidth/2, controller.navigationController.navigationBar.frame.size.height - kHeaderImageHeight, kHeaderImageWidth, kHeaderImageHeight)];
    mainImage.image = [UIImage imageNamed:@"header_img"];
    mainImage.tag = 999;
    [controller.navigationController.navigationBar addSubview:mainImage];
    
    // Get Icon size ready
    float iconSize = 35;
    
    // Get AppDelegate Ready
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.deckController setEnabled:YES];
    
    
    // Add menu button
    if (leftImage) {
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        menuButton.frame = CGRectMake(0, 0, iconSize, iconSize);
        [menuButton setImage:[UIImage imageNamed:@"3bar-01"] forState:UIControlStateNormal];
        [menuButton addTarget:appDelegate.deckController action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
        [menuButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        UIEdgeInsets insets = UIEdgeInsetsZero;
        if ([controller respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            insets = UIEdgeInsetsMake(0, -14, 0, 8);
        }
        
        [menuButton setContentEdgeInsets:insets];
        UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
        [controller.navigationItem setLeftBarButtonItem:menuItem];
    }
    else {
        if (![controller respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            // iOS 6
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            rightButton.frame = CGRectMake(0, 0, 52, 23);
            rightButton.contentMode = UIViewContentModeScaleAspectFit;
            [rightButton setImage:[UIImage imageNamed:@"nav_back_ios6-01"] forState:UIControlStateNormal];
            [rightButton addTarget:controller.navigationController action:@selector(popViewControllerAnimated:)forControlEvents:UIControlEventTouchUpInside];
            [controller.navigationItem setHidesBackButton:YES];
            [rightButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            UIBarButtonItem * menuItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
            [controller.navigationItem setLeftBarButtonItem:menuItem];
        }
    }
    
    if (rImages && rActions) {
        NSMutableArray *barButtonItems = [NSMutableArray array];
        for (int xx = 0; xx < rImages.count; xx++) {
            UIBarButtonItem *menuItem;
            if ([rImages[xx] isKindOfClass:[UIImage class]]) {
                UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
                rightButton.frame = CGRectMake(0, 0, iconSize, iconSize);
                [rightButton setImage:rImages[xx] forState:UIControlStateNormal];
                
                [rightButton addTarget:controller action:NSSelectorFromString(rActions[xx]) forControlEvents:UIControlEventTouchUpInside];
                [rightButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
                UIEdgeInsets insets = UIEdgeInsetsZero;
                if ([controller respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
                    insets = UIEdgeInsetsMake(0, 10, 0, -10);
                }
                
                [rightButton setContentEdgeInsets:insets];
                rightButton.alpha = 0.5;
                menuItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
            }
            else if ([rImages[xx] isKindOfClass:[NSString class]]) {
                if ([controller respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
                    // iOS7
                    menuItem = [[UIBarButtonItem alloc] initWithTitle:rImages[xx] style:UIBarButtonItemStylePlain target:controller action:NSSelectorFromString(rActions[xx])];
                }
                else {
                    // iOS6
                    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    rightButton.frame = CGRectMake(0, 0, 55, 23);
                    rightButton.contentMode = UIViewContentModeScaleAspectFit;
                    [rightButton setImage:[UIImage imageNamed:@"nav_submit_ios6-01"] forState:UIControlStateNormal];
                    [rightButton addTarget:controller action:NSSelectorFromString(rActions[xx]) forControlEvents:UIControlEventTouchUpInside];
                    [rightButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
                    menuItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
                }
            }
            
            if (menuItem) {
                [barButtonItems addObject:menuItem];
            }
        }
        [controller.navigationItem setRightBarButtonItems:barButtonItems];
    }
    else {
        [controller.navigationItem setRightBarButtonItems:nil];
    }
}

+ (void)navigationController:(UIViewController *)controller addActivityIndicator:(UIActivityIndicatorView **)indicator {
    float origin = controller.navigationItem.rightBarButtonItems.count*40+30;
    [*indicator setFrame:CGRectMake(controller.navigationController.navigationBar.frame.size.width - origin, controller.navigationController.navigationBar.frame.size.height/2 - 10, 20, 20)];
    [*indicator startAnimating];
    [*indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [controller.navigationController.navigationBar addSubview:*indicator];
}

+ (void)addUpvoteButtonToNavigationController:(UIViewController *)controller action:(SEL)action {
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 35, 35);
    [rightButton setImage:[UIImage imageNamed:@"upvote-01"] forState:UIControlStateNormal];
    [rightButton addTarget:controller action:action forControlEvents:UIControlEventTouchUpInside];
    [rightButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if ([controller respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        insets = UIEdgeInsetsMake(0, 10, 0, -10);
    }
    
    [rightButton setContentEdgeInsets:insets];
    rightButton.alpha = 0.5;
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    NSMutableArray *menuItems = [controller.navigationItem.rightBarButtonItems mutableCopy];
    [menuItems addObject:menuItem];
    [controller.navigationItem setRightBarButtonItems:menuItems animated:YES];
}

@end



@implementation NavBarButtonItem

- (void)setFrameForHeight:(float)height {
    self.customView.frame = CGRectMake(5, (height-35)/2, 35, 35);
}

@end
