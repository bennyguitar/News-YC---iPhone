//
//  LinksViewController.m
//  HackerNews
//
//  Created by Ben Gordon on 10/22/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "LinksViewController.h"
#import "CommentsViewController.h"
#import "Helpers.h"
#import "ARChromeActivity.h"
#import "TUSafariActivity.h"
#import "DRPocketActivity/DRPocketActivity.h"
#import "KGStatusBar.h"
#import "SVProgressHUD.h"
#import "HNPostURL.h"

@interface LinksViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *LinkWebView;
@property (nonatomic, retain) NSURL *Url;
@property (nonatomic, weak) UIActivityIndicatorView *indicator;
@property (nonatomic, retain) UIButton *shareButton;
@property (nonatomic, assign) BOOL Readability;
@property (nonatomic, retain) HNPost *Post;
@end

@implementation LinksViewController

#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSURL *)url post:(HNPost *)post
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.Url = url;
        self.Post = post;
    }
    return self;
}


#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Register for Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeReadability:) name:@"Readability" object:nil];
    
    // Set Readability
    self.Readability = [[NSUserDefaults standardUserDefaults] boolForKey:@"Readability"];
    
    // Load Nav
    [self buildNavBar];
    
    // Load Link
    [self loadWebViewWithUrl:self.Url];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.indicator.alpha = 0;
    [self.indicator removeFromSuperview];
    [[HNManager sharedManager] cancelAllRequests];
}

- (void)viewDidDisappear:(BOOL)animated {
    self.indicator.alpha = 0;
    [self.indicator removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Autoresizing
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self buildNavBar];
}


#pragma mark - UI
- (void)buildNavBar {
    // Build Nav
    NSArray *images = @[[UIImage imageNamed:@"share_button-01"]];
    NSArray *actions = @[@"didClickShare"];
    [Helpers buildNavigationController:self leftImage:NO rightImages:images rightActions:actions];
    
    // Add Upvote if Necessary
    if (self.Post.UpvoteURLAddition && [[HNManager sharedManager] userIsLoggedIn] && ![[HNManager sharedManager] hasVotedOnObject:self.Post]) {
        [Helpers addUpvoteButtonToNavigationController:self action:@selector(upvoteCurrentPost)];
    }
}

#pragma mark - Upvote
- (void)upvoteCurrentPost {
    [[HNManager sharedManager] voteOnPostOrComment:self.Post direction:VoteDirectionUp completion:^(BOOL success) {
        if (success) {
            [KGStatusBar showWithStatus:@"Voting Success"];
            [[HNManager sharedManager] addHNObjectToVotedOnDictionary:self.Post direction:VoteDirectionUp];
            self.Post.UpvoteURLAddition = nil;
            [self.Post setPoints:self.Post.Points + 1];
            [self buildNavBar];
        }
        else {
            [KGStatusBar showWithStatus:@"Failed Voting"];
        }
        
    }];
}

#pragma mark - Share
- (void)didClickShare {
    
	NSArray *activityItems = @[[self buildPostURL]];

    ARChromeActivity *chromeActivity = [[ARChromeActivity alloc] init];
	TUSafariActivity *safariActivity = [[TUSafariActivity alloc] init];
    DRPocketActivity *pocketActivity = [[DRPocketActivity alloc] init];
	NSArray *applicationActivities = @[ pocketActivity, safariActivity, chromeActivity ];
	
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
    activityController.completionHandler = ^(NSString *activityType, BOOL completed) {
        if ([activityType isEqualToString:pocketActivity.activityType]) {
            completed
            ? [SVProgressHUD showSuccessWithStatus:@"Saved to pocket"]
            : [SVProgressHUD showErrorWithStatus:@"Unable to save to pocket"];
        }
    };
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)didClickComment {
    if (self.Post) {
        CommentsViewController *vc = [[CommentsViewController alloc] initWithNibName:@"CommentsViewController" bundle:nil post:self.Post];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (HNPostURL *)buildPostURL
{
    NSString *readabilityURLString = self.LinkWebView.request.URL.absoluteString;
    NSString *originalPostUrlString = self.Post.UrlString;
    return [[HNPostURL alloc] initWithString:originalPostUrlString andMobileFriendlyString:readabilityURLString];
}


#pragma mark - Change Readability
- (void)didChangeReadability:(NSNotification *)notification {
    self.Readability = [[NSUserDefaults standardUserDefaults] boolForKey:@"Readability"];
    [self loadWebViewWithUrl:self.Url];
}


#pragma mark - Load URL
- (void)loadWebViewWithUrl:(NSURL *)url {
    if (self.Url) {
        NSURL *launchURL = self.Readability ? [NSURL URLWithString:[NSString stringWithFormat:@"http://www.readability.com/m?url=%@", [self.Url absoluteString]]] : self.Url;
        
        // Launch Activity Indicator
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
        self.indicator = indicator;
        [Helpers navigationController:self addActivityIndicator:&indicator];
        
        [self.LinkWebView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
        [self.LinkWebView loadRequest:[NSURLRequest requestWithURL:launchURL]];
    }
}


#pragma mark - Web View Delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.indicator removeFromSuperview];
}


#pragma mark - Activity result HUD
- (void)showActivityResultHUDWithText:(NSString*)text {
    [self showActivityResultHUDWithText:text andDismissAfter:0];
}
- (void)showActivityResultHUDWithText:(NSString*)text andDismissAfter:(NSTimeInterval)seconds {
    
    [SVProgressHUD showWithStatus:text];
    double delayInSeconds = seconds;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [SVProgressHUD dismiss];
    });
}

@end
