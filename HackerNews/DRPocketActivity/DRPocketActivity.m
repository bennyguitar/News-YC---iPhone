//
//  DRPocketActivity.m
//  HackerNews
//
//  Created by Daniel Rosado on 09/11/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "PocketAPI.h"
#import "DRPocketActivity.h"
#import "SVProgressHUD.h"
#import "LoadingHUDViewController.h"

@implementation DRPocketActivity {
    NSURL *_URL;
}

- (NSString *)activityType {
    return NSStringFromClass([self class]);
}

- (NSString *)activityTitle {
    return NSLocalizedStringFromTable(@"Save to Pocket", @"DRPocketActivity", nil);
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"PocketActivity.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[NSURL class]] && [[UIApplication sharedApplication] canOpenURL:activityItem]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[NSURL class]]) {
            _URL = ((NSURL*)activityItem).absoluteURL;
        }
    }
}

- (UIViewController *)activityViewController
{
    [self performSelector:@selector(saveToPocket) withObject:nil afterDelay:0];
    return [[LoadingHUDViewController alloc] initWithLoadingStatus:@"Saving..."];
}

- (void)saveToPocket {
	[[PocketAPI sharedAPI] saveURL:_URL handler: ^(PocketAPI *API, NSURL *URL, NSError *error) {
        BOOL activityCompletedSuccessfully = error ? NO : YES;
        
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self activityDidFinish:activityCompletedSuccessfully];
        });
	}];
}

@end