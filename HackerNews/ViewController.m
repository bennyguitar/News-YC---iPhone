//
//  ViewController.m
//  HackerNews
//
//  Created by Benjamin Gordon on 5/1/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "ViewController.h"
#import "CommentsViewController.h"
#import "AppDelegate.h"
#import "LinksViewController.h"

@interface ViewController () {
    // Home Page UI
    __weak IBOutlet UIView *headerContainer;
    __weak IBOutlet UITableView *frontPageTable;
    __weak IBOutlet UIImageView *underHeaderTriangle;
    __weak IBOutlet TriangleView *headerTriangle;
    __weak IBOutlet UIActivityIndicatorView *loadingIndicator;
    UIRefreshControl *frontPageRefresher;
    __weak IBOutlet UIButton *submitLinkButton;

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
    __weak IBOutlet UIActivityIndicatorView *externalActivityIndicator;
    
    // Data
    NSMutableArray *homePagePosts;
    NSArray *organizedCommentsArray;
    NSMutableArray *openFrontPageCells;
    HNPost *currentPost;
    float frontPageLastLocation;
    float commentsLastLocation;
    int scrollDirection;
}

// Change Theme
- (void)colorUI;

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil filterType:(PostFilterType)type
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.filterType = type;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Build NavBar
    [Helpers buildNavigationController:self leftImage:YES rightImage:([[HNManager sharedManager] userIsLoggedIn] ? [UIImage imageNamed:@"submit_button-01"] : nil) rightAction:([[HNManager sharedManager] userIsLoggedIn] ? @selector(didClickSubmitLink) : nil)];
	
    // Set Up Data
    homePagePosts = [@[] mutableCopy];
    organizedCommentsArray = @[];
    openFrontPageCells = [@[] mutableCopy];
    frontPageLastLocation = 0;
    commentsLastLocation = 0;
    
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
    
    // Redraw View
    [self.view setNeedsDisplay];
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
    commentsTable.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        [self colorUI];
    } completion:^(BOOL fin){
        [frontPageTable reloadData];
        [commentsTable reloadData];
        [UIView animateWithDuration:0.2 animations:^{
            frontPageTable.alpha = 1;
            commentsTable.alpha = 1;
        }];
    }];
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
    
}


#pragma mark - Did Login
-(void)didLoginOrOut {
    // Show paper airplane icon to open submit link
    // in right drawer. I might move this to the
    // left drawer instead.
    if ([HNManager sharedManager].SessionUser) {
        loadingIndicator.frame = kLoadingRectSubmit;
        submitLinkButton.alpha = 1;
    }
    else {
        loadingIndicator.frame = kLoadingRectNoSubmit;
        submitLinkButton.alpha = 0;
    }
}


#pragma mark - Load HomePage
-(void)loadHomepage {
    // Clear fnid
    [[HNManager sharedManager] setPostFNID:nil];
    
    // Add activity indicator
    __block UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    [Helpers navigationController:self addActivityIndicator:&indicator];
    
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


#pragma mark - Load Comments
-(void)loadCommentsForPost:(HNPost *)post {
    /*
    // Activity Indicator
    __block UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    [Helpers navigationController:self.navigationController addActivityIndicator:&indicator];
    
    // Load Comments
    [[HNManager sharedManager] loadCommentsFromPost:post completion:^(NSArray *comments) {
        if (comments) {
            currentPost = post;
            organizedCommentsArray = comments;
            [commentsTable reloadData];
            [commentsTable setContentOffset:CGPointZero animated:YES];
            [self launchCommentsView];
            [self endRefreshing:commentsRefresher];
            indicator.alpha = 0;
            [indicator removeFromSuperview];
        }
        else {
            [FailedLoadingView launchFailedLoadingInView:self.view];
            [self endRefreshing:commentsRefresher];
            indicator.alpha = 0;
            [indicator removeFromSuperview];
        }
    }];
     */
    
    CommentsViewController *vc = [[CommentsViewController alloc] initWithNibName:@"CommentsViewController" bundle:nil post:post];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - UIRefreshControl Stuff
-(void)endRefreshing:(UIRefreshControl *)refresher {
    [refresher endRefreshing];
    loadingIndicator.alpha = 0;
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
            
            NSLog(@"%@", [HNManager sharedManager].postFNID);
            [[HNManager sharedManager] loadPostsWithFNID:[[HNManager sharedManager] postFNID] completion:^(NSArray *posts) {
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
    if (tableView == frontPageTable) {
        return homePagePosts.count;
    }
    
    else {
        if (organizedCommentsArray.count > 0) {
            return organizedCommentsArray.count;
        }
        else {
            return 1;
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Front Page
    if (tableView == frontPageTable) {
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
    
    // Comments Cell
    else  {
        NSString *CellIdentifier = [NSString stringWithFormat:@"Cell %d", indexPath.row];
        CommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"CommentsCell" owner:nil options:nil];
            for (UIView *view in views) {
                if([view isKindOfClass:[UITableViewCell class]]) {
                    cell = (CommentsCell *)view;
                }
            }
        }
        
        cell = [cell cellForComment:(organizedCommentsArray.count > 0 ? organizedCommentsArray[indexPath.row] : nil) atIndex:indexPath fromController:self];
        [cell.comment setDelegate:self];
        //cell.comment.delegate = self;
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == frontPageTable) {
        // Set Current Post
        currentPost = homePagePosts[indexPath.row];
        
        // Mark As Read
        [[HNManager sharedManager] setMarkAsReadForPost:currentPost];
        
        // Launch LinkView
        if (currentPost.Type == PostTypeAskHN) {
            [self loadCommentsForPost:currentPost];
        }
        else {
            if (currentPost.Type == PostTypeJobs && [currentPost.UrlString rangeOfString:@"http"].location == NSNotFound) {
                [self loadCommentsForPost:currentPost];
            }
            else {
                NSURL *linkUrl = [NSURL URLWithString:currentPost.UrlString];
                LinksViewController *vc = [[LinksViewController alloc] initWithNibName:@"LinksViewController" bundle:nil url:linkUrl];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        
        // Reload table so Mark As Read will show up
        [frontPageTable reloadData];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Comment Cell Height
    if (tableView == commentsTable) {
        NSString *CellIdentifier = [NSString stringWithFormat:@"Cell %d", indexPath.row];
        CommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"CommentsCell" owner:nil options:nil];
            for (UIView *view in views) {
                if([view isKindOfClass:[UITableViewCell class]]) {
                    cell = (CommentsCell *)view;
                }
            }
        }
        
        return [cell heightForComment:(organizedCommentsArray.count > 0 ? organizedCommentsArray[indexPath.row] : nil)];
    }
    
    // Front Page Cell Height
    return kFrontPageCellHeight;
}

-(void)hideNestedCommentsCell:(UIButton *)commentButton {
    NSMutableArray *rowArray = [@[] mutableCopy];
    //HNComment *clickComment = organizedCommentsArray[commentButton.tag];
    
    // Close Comment and make hidden all nested Comments
    /*
    if (clickComment.CellType == CommentTypeOpen) {
        clickComment.CellType = CommentTypeClickClosed;
        [rowArray addObject:[NSIndexPath indexPathForRow:commentButton.tag inSection:0]];
        
        for (int xx = commentButton.tag + 1; xx < organizedCommentsArray.count; xx++) {
            Comment *newComment = organizedCommentsArray[xx];
            if (newComment.Level > clickComment.Level) {
                newComment.CellType = CommentTypeHidden;
                [rowArray addObject:[NSIndexPath indexPathForRow:xx inSection:0]];
            }
            else {
                break;
            }
        }
    }
    
    // Open Comment and all nested Comments
    else {
        clickComment.CellType = CommentTypeOpen;
        [rowArray addObject:[NSIndexPath indexPathForRow:commentButton.tag inSection:0]];
        
        for (int xx = commentButton.tag + 1; xx < organizedCommentsArray.count; xx++) {
            Comment *newComment = organizedCommentsArray[xx];
            if (newComment.Level > clickComment.Level) {
                newComment.CellType = CommentTypeOpen;
                [rowArray addObject:[NSIndexPath indexPathForRow:xx inSection:0]];
            }
            else {
                break;
            }
        }
    }
     */
    
    // Reload the table with a nice animation
    [commentsTable reloadRowsAtIndexPaths:rowArray withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Table Gesture Recognizers
/*
-(void)longPressFrontPageCell:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if ([HNSingleton sharedHNSingleton].User) {
            NSIndexPath *indexPath = [frontPageTable indexPathForRowAtPoint:[recognizer locationInView:frontPageTable]];
            if (indexPath) {
                if ([[homePagePosts objectAtIndex:indexPath.row] isOpenForActions]) {
                    [[homePagePosts objectAtIndex:indexPath.row] setIsOpenForActions:NO];
                    [frontPageTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    openFrontPageCells = [@[] mutableCopy];
                }
                else {
                    for (NSIndexPath *index in openFrontPageCells) {
                        Post *post = homePagePosts[index.row];
                        post.isOpenForActions = NO;
                    }
                    [[homePagePosts objectAtIndex:indexPath.row] setIsOpenForActions:YES];
                    [openFrontPageCells addObject:indexPath];
                    [frontPageTable reloadRowsAtIndexPaths:openFrontPageCells withRowAnimation:UITableViewRowAnimationFade];
                    openFrontPageCells = [@[indexPath] mutableCopy];
                }
            }
        }
    }
}
*/

#pragma mark - Front Page Voting Actions
/*
-(void)voteUp:(UIButton *)voteButton {
    if ([HNSingleton sharedHNSingleton].User) {
        [HNService voteUp:YES forObject:[homePagePosts objectAtIndex:voteButton.tag]];
    }
}

-(void)voteDown:(UIButton *)voteButton {
    if ([HNSingleton sharedHNSingleton].User) {
        [HNService voteUp:NO forObject:[homePagePosts objectAtIndex:voteButton.tag]];
    }
}
 */

#pragma mark - Launch/Hide Comments & Link View
-(void)didClickCommentsFromHomepage:(UIButton *)commentButton {
    currentPost = [homePagePosts objectAtIndex:commentButton.tag];
    [self loadCommentsForPost:currentPost];
}

-(void)launchCommentsView {
    // Set Post-Title Label
    postTitleLabel.text = currentPost.Title;
    
    // Set frames
    commentsView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    commentsHeader.frame = CGRectMake(0, 0, commentsHeader.frame.size.width, commentsHeader.frame.size.height);
    commentsTable.frame = CGRectMake(0, commentsHeader.frame.size.height, commentsView.frame.size.width, commentsView.frame.size.height - commentsHeader.frame.size.height);
    
    // Add to self.view
    [self.view addSubview:commentsView];
    [self.view bringSubviewToFront:commentsView];
    
    // Scroll to Top
    [commentsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    // Animate everything
    [UIView animateWithDuration:0.3 animations:^{
        [frontPageTable setScrollEnabled:NO];
        [frontPageTable setContentOffset:frontPageTable.contentOffset animated:NO];
        commentsView.frame = CGRectMake(0, 0, commentsView.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL fin){
        [frontPageTable setScrollEnabled:YES];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }];
}

- (IBAction)hideCommentsAndLinkView:(id)sender {
    // Stop the linkWebView from loading
    // - Wrapped in the delegate-killer to prevent any
    // - animations from happening after.
    linkWebView.delegate = nil;
    [linkWebView stopLoading];
    linkWebView.delegate = self;
    
    // These make sure the comments don't re-open after closing
    if ([commentsTable isDragging]) {
        [commentsTable setContentOffset:commentsTable.contentOffset animated:NO];
    }
    if (commentsTable.contentOffset.y < 0  || commentsTable.contentSize.height <= self.view.frame.size.height){
        [commentsTable setContentOffset:CGPointZero animated:NO];
    }
    
    // End editing inside the webView
    [self.view endEditing:YES];
    
    // Animate everything
    [UIView animateWithDuration:0.3 animations:^{
        commentsView.frame = CGRectMake(0, self.view.frame.size.height, commentsView.frame.size.width, frontPageTable.frame.size.height);
        linkView.frame = CGRectMake(0, self.view.frame.size.height, linkView.frame.size.width, linkView.frame.size.height);
    } completion:^(BOOL fin){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }];
}

- (IBAction)showSharePanel:(id)sender {	
	NSURL *urlToShare = linkWebView.request.URL;
	NSArray *activityItems = @[ urlToShare ];
	
    ARChromeActivity *chromeActivity = [[ARChromeActivity alloc] init];	
	TUSafariActivity *safariActivity = [[TUSafariActivity alloc] init];
	NSArray *applicationActivities = @[ safariActivity, chromeActivity ];
	
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
	//activityController.excludedActivityTypes = @[ UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypeMessage, UIActivityTypeMail, UIActivityTypeCopyToPasteboard ];
	
    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - WebView Delegate
-(void)webViewDidStartLoad:(UIWebView *)webView {
    if (webView == externalLinkWebView) {
        externalActivityIndicator.alpha = 1;
    }
    else {
        loadingIndicator.alpha = 1;
    }
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView == externalLinkWebView) {
        externalActivityIndicator.alpha = 0;
    }
    else {
        loadingIndicator.alpha = 0;
        [UIView animateWithDuration:0.25 animations:^{
            headerContainer.frame = CGRectMake(0, -1*headerContainer.frame.size.height, headerContainer.frame.size.width, headerContainer.frame.size.height);
            linkView.frame = CGRectMake(0, 0, linkView.frame.size.width,self.view.frame.size.height);
        }];
    }
}

@end
