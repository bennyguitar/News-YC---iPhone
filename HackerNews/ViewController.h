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
#import "CommentsCell.h"
#import "Helpers.h"
#import "LinkButton.h"

#define kPad 10

@interface ViewController : UIViewController <WebserviceDelegate, UITableViewDataSource, UITableViewDelegate> {
    // Home Page UI
    __weak IBOutlet UIView *headerContainer;
    __weak IBOutlet UITableView *frontPageTable;
    __weak IBOutlet UIImageView *underHeaderTriangle;
    __weak IBOutlet TriangleView *headerTriangle;
    __weak IBOutlet UIActivityIndicatorView *loadingIndicator;
    UIRefreshControl *frontPageRefresher;
    
    // Comments Page UI
    IBOutlet UIView *commentsView;
    __weak IBOutlet UIView *commentsHeader;
    __weak IBOutlet UITableView *commentsTable;
    __weak IBOutlet UILabel *commentPostTitleLabel;
    UIRefreshControl *commentsRefresher;
    __weak IBOutlet UILabel *postTitleLabel;
    
    
    // Link Page UI
    __weak IBOutlet UIView *linkHeader;
    __weak IBOutlet UIWebView *linkWebView;
    IBOutlet UIView *linkView;
    
    // External Link View
    __weak IBOutlet UIWebView *externalLinkWebView;
    IBOutlet UIView *externalLinkView;
    __weak IBOutlet UIView *externalLinkHeader;
    
    
    // Data
    NSArray *homePagePosts;
    NSArray *organizedCommentsArray;
    Post *currentPost;
    float frontPageLastLocation;
    float commentsLastLocation;
    int scrollDirection;
}

- (IBAction)didClickCommentsFromLinkView:(id)sender;
- (IBAction)hideCommentsAndLinkView:(id)sender;
- (IBAction)didClickLinkViewFromComments:(id)sender;
- (IBAction)didClickBackToComments:(id)sender;

@end
