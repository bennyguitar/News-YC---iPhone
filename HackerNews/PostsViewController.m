//
//  ViewController.m
//  HackerNews
//
//  Created by Benjamin Gordon on 5/1/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "PostsViewController.h"
#import "CommentsViewController.h"
#import "AppDelegate.h"
#import "LinksViewController.h"
#import "SubmitHNViewController.h"

@interface PostsViewController () {
    // Home Page UI
    __weak IBOutlet UITableView *frontPageTable;
    UIRefreshControl *frontPageRefresher;    // Data
    NSMutableArray *homePagePosts;
    HNPost *currentPost;
    LinksViewController *previousLinksViewController;
    CommentsViewController *previousCommentsViewController;
}

@property (nonatomic, retain) NSString *Username;
@property (nonatomic, assign) BOOL isLoadingFromFNID;

// Change Theme
- (void)colorUI;

@end

@implementation PostsViewController

#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil filterType:(PostFilterType)type
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.filterType = type;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil username:(NSString *)user {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.Username = user;
    }
    return self;
}


#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Build NavBar
    [self buildNavBar];
	
    // Set Up Data
    homePagePosts = [@[] mutableCopy];
    
    // Run methods
    [self loadHomepage];
    [self buildUI];
    [self colorUI];
    //[self setScrollViewToScrollToTop:frontPageTable];

    // Set Up NotificationCenter
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeTheme) name:@"DidChangeTheme" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoginOrOut) name:@"DidLoginOrOut" object:nil];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // Add Gesture Recognizers
    /*
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFrontPageCell:)];
    longPress.minimumPressDuration = 0.7;
    longPress.delegate = self;
    [frontPageTable addGestureRecognizer:longPress];
     */
}

- (void)viewDidAppear:(BOOL)animated {
    [self setSizes];
    NSLog(@"%@", NSStringFromCGRect(frontPageTable.frame));
}


#pragma mark - Memory
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UI
-(void)buildUI {
    // Add Refresh Controls
    frontPageRefresher = [[UIRefreshControl alloc] init];
    [frontPageRefresher addTarget:self action:@selector(loadHomepage) forControlEvents:UIControlEventValueChanged];
    frontPageRefresher.tintColor = [UIColor blackColor];
    frontPageRefresher.alpha = 0.65;
    [frontPageTable addSubview:frontPageRefresher];
}

-(void)colorUI {
    // Set Colors for all objects based on Theme
    self.view.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"CellBG"];
    frontPageTable.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"CellBG"];
    frontPageTable.separatorColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"Separator"];
}

-(void)setSizes {
    // Sizes
    frontPageTable.frame = CGRectMake(0, 0, frontPageTable.frame.size.width, self.view.frame.size.height);
    //[frontPageTable setContentOffset:CGPointZero];
}

-(void)didChangeTheme {
    // Set alphas to 0 for tables
    // Color the UI
    // Reload tables, and set their alphas to 1
    
    frontPageTable.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        [self colorUI];
    } completion:^(BOOL fin){
        [frontPageTable reloadData];
        [UIView animateWithDuration:0.2 animations:^{
            frontPageTable.alpha = 1;
        }];
    }];
}

- (void)buildNavBar {
    // Build NavBar
    [Helpers buildNavigationController:self leftImage:YES rightImages:([[HNManager sharedManager] userIsLoggedIn] ? @[[UIImage imageNamed:@"submit_button-01"]] : nil) rightActions:([[HNManager sharedManager] userIsLoggedIn] ? @[@"didClickSubmitLink"] : nil)];
}

#pragma mark - Toggle Nav
- (IBAction)toggleSideNav:(id)sender {
    [self.viewDeckController toggleLeftView];
}

-(IBAction)toggleRightNav:(id)sender {
    [self.viewDeckController toggleRightView];
}


#pragma mark - Submit Link
- (void)didClickSubmitLink {
    SubmitHNViewController *vc = [[SubmitHNViewController alloc] initWithNibName:@"SubmitHNViewController" bundle:nil type:SubmitHNTypePost hnObject:nil commentIndex:0];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Did Login
-(void)didLoginOrOut {
    [self buildNavBar];
}


#pragma mark - Load HomePage
-(void)loadHomepage {
    // Clear fnid
    [[HNManager sharedManager] setPostUrlAddition:nil];
    
    // Add activity indicator
    __block UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    [Helpers navigationController:self addActivityIndicator:&indicator];
    
    if (self.Username) {
        // Load Posts for User
        [[HNManager sharedManager] fetchSubmissionsForUser:self.Username completion:^(NSArray *posts) {
            if (posts) {
                homePagePosts = [posts mutableCopy];
                [frontPageTable reloadData];
                [self endRefreshing:frontPageRefresher];
                indicator.alpha = 0;
                [indicator removeFromSuperview];
            }
            else {
                [FailedLoadingView launchFailedLoadingInView:self.view];
                [self endRefreshing:frontPageRefresher];
                indicator.alpha = 0;
                [indicator removeFromSuperview];
            }
            
        }];
    }
    else {
        // Load Posts
        [[HNManager sharedManager] loadPostsWithFilter:self.filterType completion:^(NSArray *posts) {
            if (posts) {
                homePagePosts = [posts mutableCopy];
                [frontPageTable reloadData];
                [self endRefreshing:frontPageRefresher];
                indicator.alpha = 0;
                [indicator removeFromSuperview];
            }
            else {
                [FailedLoadingView launchFailedLoadingInView:self.view];
                [self endRefreshing:frontPageRefresher];
                indicator.alpha = 0;
                [indicator removeFromSuperview];
            }
        }];
    }
}


#pragma mark - Load Comments
-(void)loadCommentsForPost:(HNPost *)post {
    if (previousCommentsViewController.Post.PostId != post.PostId) {
        CommentsViewController *vc = [[CommentsViewController alloc] initWithNibName:@"CommentsViewController" bundle:nil post:post];
        previousCommentsViewController = vc;
    }
    
    [self.navigationController pushViewController:previousCommentsViewController animated:YES];
}

#pragma mark - Load Links
-(void)loadLinksForPost:(HNPost *)post {
    if (previousLinksViewController.Post.PostId != post.PostId) {
        NSURL *linkUrl = [NSURL URLWithString:currentPost.UrlString];
        LinksViewController *vc = [[LinksViewController alloc] initWithNibName:@"LinksViewController" bundle:nil url:linkUrl post:currentPost];
        previousLinksViewController = vc;
    }
    
    [self.navigationController pushViewController:previousLinksViewController animated:YES];
}

#pragma mark - UIRefreshControl Stuff
-(void)endRefreshing:(UIRefreshControl *)refresher {
    [refresher endRefreshing];
}


#pragma mark - Vote for HNObject
-(void)voteForPost:(HNPost *)post {
    [[HNManager sharedManager] voteOnPostOrComment:post direction:VoteDirectionUp completion:^(BOOL success) {
        NSLog(@"%d", success);
    }];
}


#pragma mark - Scroll View Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == frontPageTable) {
        // Use current fnid to grab latest posts
        if ([[frontPageTable indexPathsForVisibleRows].lastObject row] == homePagePosts.count - 3 && self.isLoadingFromFNID == NO) {
            self.isLoadingFromFNID = YES;
            __block UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
            [Helpers navigationController:self addActivityIndicator:&indicator];
            
            // Load Posts
            [[HNManager sharedManager] loadPostsWithUrlAddition:(self.Username ? [[HNManager sharedManager] userSubmissionUrlAddition] : [[HNManager sharedManager] postUrlAddition]) completion:^(NSArray *posts) {
                if (posts) {
                    indicator.alpha = 0;
                    [indicator removeFromSuperview];
                    if (posts.count > 0) {
                        [homePagePosts addObjectsFromArray:posts];
                        [frontPageTable reloadData];
                        self.isLoadingFromFNID = NO;
                    }
                    else {
                        // Lock loading from FNID so it doesn't slam HN servers
                        self.isLoadingFromFNID = YES;
                    }
                }
                else {
                    // Loading from FNID realllllly failed
                    [FailedLoadingView launchFailedLoadingInView:self.view];
                    self.isLoadingFromFNID = YES;
                    indicator.alpha = 0;
                    [indicator removeFromSuperview];
                }
            }];
        }
    }
}

#pragma mark - TableView Delegate
-(int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return homePagePosts.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Front Page
    NSString *CellIdentifier = @"frontPageCell";
    frontPageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"frontPageCell" owner:nil options:nil];
        for (UIView *view in views) {
            if([view isKindOfClass:[UITableViewCell class]]) {
                cell = (frontPageCell *)view;
            }
        }
    }
    
    cell = [cell setCellWithPost:(homePagePosts.count > 0 ? homePagePosts[indexPath.row] : nil) atIndex:indexPath fromController:self];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Set Current Post
    currentPost = homePagePosts[indexPath.row];
	
    // Launch LinkView
    if (currentPost.Type == PostTypeAskHN) {
        [self loadCommentsForPost:currentPost];
    }
    else {
        if (currentPost.Type == PostTypeJobs && [currentPost.UrlString rangeOfString:@"http"].location == NSNotFound) {
            [self loadCommentsForPost:currentPost];
        }
        else {
            [self loadLinksForPost:currentPost];
        }
    }
    
    // Mark As Read
    [[HNManager sharedManager] setMarkAsReadForPost:currentPost];
    [frontPageTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kFrontPageCellHeight;
}

#pragma mark - Launch/Hide Comments & Link View
-(void)didClickCommentsFromHomepage:(UIButton *)commentButton {
    // Set Current Post
    currentPost = [homePagePosts objectAtIndex:commentButton.tag];
    
    // Set Mark As Read for AskHN
    if (currentPost.Type == PostTypeAskHN) {
        [[HNManager sharedManager] setMarkAsReadForPost:currentPost];
        // Reload table so Mark As Read will show up
        [frontPageTable reloadData];
    }
    
    [self loadCommentsForPost:currentPost];
}

@end
