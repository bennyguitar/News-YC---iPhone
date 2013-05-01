//
//  ViewController.h
//  HackerNews
//
//  Created by Benjamin Gordon on 5/1/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Webservice.h"
#import "TriangleView.h"
#import "HNSingleton.h"
#import "frontPageCell.h"

@interface ViewController : UIViewController <WebserviceDelegate, UITableViewDataSource, UITableViewDelegate> {
    // Home Page UI
    __weak IBOutlet UIView *headerContainer;
    __weak IBOutlet UITableView *frontPageTable;
    __weak IBOutlet TriangleView *headerTriangle;
    __weak IBOutlet UIActivityIndicatorView *loadingIndicator;
    
    // Comments Page UI
    __weak IBOutlet UIView *commentsHeader;
    
    
    // Link Page UI
    __weak IBOutlet UIView *linkHeader;
    
    
    // Data
    NSArray *homePagePosts;
    float frontPageLastLocation;
    int scrollDirection;
}



@end
