//
//  AppDelegate.m
//  HackerNews
//
//  Created by Benjamin Gordon on 5/1/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "AppDelegate.h"
#import "PostsViewController.h"
#import "IIViewDeckController.h"
#import "NavigationDeckViewController.h"
#import "HNManager.h"
#import "PocketAPI.h"
#import "SatelliteStore.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	//Register in the Pocket API.
	[[PocketAPI sharedAPI] setConsumerKey:@"20118-9a164e727c7246cdc440dcab"];
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Set Pro & Start HNManager Session
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Pro"]) {
        [[HNManager sharedManager] startSession];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Pro"];
    }
    
    // Check Theme
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"HNTheme"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:HNThemeTypeNight forKey:@"HNTheme"];
    }
    
    // Set Theme
    [HNTheme changeThemeToType:[[NSUserDefaults standardUserDefaults] integerForKey:@"HNTheme"]];
    
    // If no User Default for Readability, turn it ON!
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Readability"] == nil) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Readability"];
    }
    // If no User Default for MarkAsRead, turn it ON!
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"MarkAsRead"] == nil) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MarkAsRead"];
    }
    
    // SatelliteStore: Set Up Store
    [[SatelliteStore shoppingCenter] setProductIdentifiers:@[kProProductID]];
    
    // SatelliteStore: Get Pro Products
    [[SatelliteStore shoppingCenter] getProductsWithCompletion:^(BOOL success) {
        //
    }];
    
    // Set View Controllers
    self.leftController = [[NavigationDeckViewController alloc] initWithNibName:@"NavigationDeckViewController" bundle:nil];
    PostsViewController *centerController = [[PostsViewController alloc] initWithNibName:@"PostsViewController" bundle:nil filterType:PostFilterTypeTop];
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[PocketAPI sharedAPI] handleOpenURL:url]) {
        return YES;
    } else {
        // Handle other url-schemes here.
        return NO;
    }
}

@end
