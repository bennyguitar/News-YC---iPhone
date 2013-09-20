//
//  AppDelegate.m
//  HackerNews
//
//  Created by Benjamin Gordon on 5/1/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "IIViewDeckController.h"
#import "NavigationDeckViewController.h"
#import "SubmitLinkViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // Check Theme
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Theme"]) {
        [[HNSingleton sharedHNSingleton] changeTheme];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setValue:@"Night" forKey:@"Theme"];
        [[HNSingleton sharedHNSingleton] changeTheme];
    }
    
    // If no User Default for Readability, turn it ON!
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Readability"] == nil) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Readability"];
    }
    // If no User Default for MarkAsRead, turn it ON!
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"MarkAsRead"] == nil) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MarkAsRead"];
    }

    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    sharedCache = nil;
    
    // Set initial filter to Top
    [HNSingleton sharedHNSingleton].filter = fTypeTop;
    
    // Login to previous account
    if (kProfile) {
        // Get Cookie for Login
        [[HNSingleton sharedHNSingleton] setSession];
        // If Cookie, fetch User object
        if ([HNSingleton sharedHNSingleton].SessionCookie && [[[NSUserDefaults standardUserDefaults] valueForKey:@"Password"] length] > 0) {
            [[HNSingleton sharedHNSingleton] loginWithUser:[[NSUserDefaults standardUserDefaults] valueForKey:@"Username"] password:[[NSUserDefaults standardUserDefaults] valueForKey:@"Password"]];
        }
    }
    
    self.leftController = [[NavigationDeckViewController alloc] initWithNibName:@"NavigationDeckViewController" bundle:nil];
    self.rightController = [[SubmitLinkViewController alloc] initWithNibName:@"SubmitLinkViewController" bundle:nil];
    ViewController *centerController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil filterType:FilterTypeTop];
    self.centerController = [[UINavigationController alloc] initWithRootViewController:centerController];
    self.deckController =  [[IIViewDeckController alloc] initWithCenterViewController:self.centerController
                                                                                    leftViewController:self.leftController
                                                                                   rightViewController:nil];
    
    self.window.rootViewController = self.deckController;
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
