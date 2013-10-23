//
//  LinksViewController.m
//  HackerNews
//
//  Created by Ben Gordon on 10/22/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "LinksViewController.h"
#import "Helpers.h"
#import "HNManager.h"
#import "ARChromeActivity.h"
#import "TUSafariActivity.h"

@interface LinksViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *LinkWebView;
@property (nonatomic, retain) NSURL *Url;
@property (nonatomic, weak) UIActivityIndicatorView *indicator;
@property (nonatomic, retain) UIButton *shareButton;
@property (nonatomic, assign) BOOL Readability;
@end

@implementation LinksViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSURL *)url
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.Url = url;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Register for Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeReadability:) name:@"Readability" object:nil];
    
    // Set Readability
    self.Readability = [[NSUserDefaults standardUserDefaults] boolForKey:@"Readability"];
    
    // Build Nav
    [Helpers buildNavigationController:self leftImage:NO rightImage:[UIImage imageNamed:@"share_button-01"] rightAction:@selector(didClickShare)];
    
    // Load Link
    [self loadWebViewWithUrl:self.Url];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.indicator.alpha = 0;
    [self.indicator removeFromSuperview];
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

#pragma mark - Share
- (void)didClickShare {
    NSURL *urlToShare = self.LinkWebView.request.URL;
	NSArray *activityItems = @[ urlToShare ];
	
    ARChromeActivity *chromeActivity = [[ARChromeActivity alloc] init];
	TUSafariActivity *safariActivity = [[TUSafariActivity alloc] init];
	NSArray *applicationActivities = @[ safariActivity, chromeActivity ];
	
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
	//activityController.excludedActivityTypes = @[ UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypeMessage, UIActivityTypeMail, UIActivityTypeCopyToPasteboard ];
	
    [self presentViewController:activityController animated:YES completion:nil];
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

@end
