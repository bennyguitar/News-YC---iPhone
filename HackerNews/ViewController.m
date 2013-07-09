//
//  ViewController.m
//  HackerNews
//
//  Created by Benjamin Gordon on 5/1/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "ViewController.h"

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

    // Webservice
    Webservice *HNService;
    
    // Data
    NSArray *homePagePosts;
    NSArray *organizedCommentsArray;
    NSMutableArray *openFrontPageCells;
    Post *currentPost;
    float frontPageLastLocation;
    float commentsLastLocation;
    int scrollDirection;
}

// Change Theme
- (void)colorUI;
- (IBAction)toggleSideNav:(id)sender;
- (IBAction)toggleRightNav:(id)sender;

- (IBAction)didClickCommentsFromLinkView:(id)sender;
- (IBAction)hideCommentsAndLinkView:(id)sender;
- (IBAction)didClickLinkViewFromComments:(id)sender;
- (IBAction)didClickBackToComments:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
	
    // Set Up Data
    homePagePosts = @[];
    organizedCommentsArray = @[];
    openFrontPageCells = [@[] mutableCopy];
    frontPageLastLocation = 0;
    commentsLastLocation = 0;
    HNService = [[Webservice alloc] init];
    HNService.delegate = self;
    
    // Run methods
    [self loadHomepage];
    [self buildUI];
    [self colorUI];
    [self setScrollViewToScrollToTop:frontPageTable];

    // Set Up NotificationCenter
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeTheme) name:@"DidChangeTheme" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoginOrOut) name:@"DidLoginOrOut" object:nil];
    
    // Add Gesture Recognizers
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFrontPageCell:)];
    longPress.minimumPressDuration = 0.7;
    longPress.delegate = self;
    [frontPageTable addGestureRecognizer:longPress];
}


#pragma mark - Memory
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI
-(void)buildUI {
    // Sizes
    headerContainer.frame = CGRectMake(0, 0, headerContainer.frame.size.width, headerContainer.frame.size.height);
    frontPageTable.frame = CGRectMake(0, headerContainer.frame.size.height, frontPageTable.frame.size.width, [[UIScreen mainScreen] bounds].size.height - headerContainer.frame.size.height - 20);
    
    // Add Refresh Controls
    frontPageRefresher = [[UIRefreshControl alloc] init];
    [frontPageRefresher addTarget:self action:@selector(loadHomepage) forControlEvents:UIControlEventValueChanged];
    frontPageRefresher.tintColor = [UIColor blackColor];
    frontPageRefresher.alpha = 0.38;
    [frontPageTable addSubview:frontPageRefresher];
    
    commentsRefresher = [[UIRefreshControl alloc] init];
    [commentsRefresher addTarget:self action:@selector(reloadComments) forControlEvents:UIControlEventValueChanged];
    commentsRefresher.tintColor = [UIColor blackColor];
    commentsRefresher.alpha = 0.38;
    [commentsTable addSubview:commentsRefresher];
    
    // Add Shadows
    NSArray *sArray = @[commentsHeader, headerContainer, linkHeader];
    for (UIView *view in sArray) {
        [Helpers makeShadowForView:view withRadius:0];
    }
}

-(void)colorUI {
    // Set Colors for all objects based on Theme
    self.view.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"CellBG"];
    frontPageTable.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"CellBG"];
    frontPageTable.separatorColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"Separator"];
    commentsTable.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"CellBG"];
    underHeaderTriangle.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"TableTriangle"];
    headerTriangle.color = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"TableTriangle"];
    [headerTriangle drawTriangleAtXPosition:self.view.frame.size.width/2];
    
    // Redraw View
    [self.view setNeedsDisplay];
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

#pragma mark - Did Login
-(void)didLoginOrOut {
    /*
    // Show paper airplane icon to open submit link
    // in right drawer. I might move this to the
    // left drawer instead.
    if ([HNSingleton sharedHNSingleton].User) {
        loadingIndicator.frame = kLoadingRectSubmit;
        submitLinkButton.alpha = 1;
    }
    else {
        loadingIndicator.frame = kLoadingRectNoSubmit;
        submitLinkButton.alpha = 0;
    }
     */
}


#pragma mark - Load HomePage
-(void)loadHomepage {
    [HNService getHomepage];
    loadingIndicator.alpha = 1;
}

-(void)webservice:(Webservice *)webservice didFetchPosts:(NSArray *)posts {
    if (posts) {
        // Handle
        homePagePosts = posts;
        [frontPageTable reloadData];
    }
    else {
        // No posts were retrieved. Handle exception.
        [FailedLoadingView launchFailedLoadingInView:self.view];
    }
    
    // Stop Activity Indicators
    loadingIndicator.alpha = 0;
    [frontPageRefresher endRefreshing];
}

#pragma mark - Load Comments
-(void)loadCommentsForPost:(Post *)post {
    [HNService getCommentsForPost:post launchComments:YES];
    loadingIndicator.alpha = 1;
    
    // Set current post
    currentPost = post;
}

-(void)reloadComments {
    [HNService getCommentsForPost:currentPost launchComments:NO];
    [commentsRefresher beginRefreshing];
    loadingIndicator.alpha = 1;
}

-(void)webservice:(Webservice *)webservice didFetchComments:(NSArray *)comments forPostID:(NSString *)postID launchComments:(BOOL)launch {
    if (comments) {
        organizedCommentsArray = comments;
        [commentsTable reloadData];
        if (launch) {
            [self launchCommentsView];
        }
    }
    else {
        // No comments were retrieved. Handle exception.
        [FailedLoadingView launchFailedLoadingInView:self.view];
    }
    
    [commentsRefresher endRefreshing];
    loadingIndicator.alpha = 0;
}

#pragma mark - Vote for HNObject
-(void)voteForPost:(Post *)post {
    [HNService voteUp:YES forObject:post];
}

-(void)webservice:(Webservice *)webservice didVoteWithSuccess:(BOOL)success forObject:(id)object direction:(BOOL)up {
    if (success) {
        [[HNSingleton sharedHNSingleton] addToVotedForDictionary:object votedUp:up];
        [frontPageTable reloadData];
    }
    else {
        
    }
}

#pragma mark - Scroll View Delegate
// This method handles the hiding header bar on frontPageTable scroll
// - it checks contentOffset and moves the header bar up/down and
// - resizes the tableview accordingly.
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == frontPageTable) {
        if (frontPageLastLocation < scrollView.contentOffset.y) {
            scrollDirection = scrollDirectionUp;
        }
        else {
            scrollDirection = scrollDirectionDown;
        }
        
        if (loadingIndicator.alpha == 1) {
            headerContainer.frame = CGRectMake(0, 0, headerContainer.frame.size.width, headerContainer.frame.size.height);
        }
        else {
            if (scrollDirection == scrollDirectionUp) {
                if (scrollView.contentOffset.y <= headerContainer.frame.size.height) {
                    headerContainer.frame = CGRectMake(0, -1*scrollView.contentOffset.y, headerContainer.frame.size.width, headerContainer.frame.size.height);
                    scrollView.frame = CGRectMake(0, headerContainer.frame.origin.y + headerContainer.frame.size.height, scrollView.frame.size.width,[[UIScreen mainScreen] bounds].size.height - (headerContainer.frame.size.height + headerContainer.frame.origin.y) - 20);
                    frontPageLastLocation = scrollView.contentOffset.y;
                }
                // This just ensures you can't fast-scroll, keeping the header off-screen
                // if the contentOffset is > header.height
                else if (scrollView.contentOffset.y > headerContainer.frame.size.height && (headerContainer.frame.origin.y != (-1*headerContainer.frame.size.height))) {
                    headerContainer.frame = CGRectMake(0, -1*headerContainer.frame.size.height, headerContainer.frame.size.width, headerContainer.frame.size.height);
                    scrollView.frame = CGRectMake(0, headerContainer.frame.origin.y + headerContainer.frame.size.height, scrollView.frame.size.width,[[UIScreen mainScreen] bounds].size.height - (headerContainer.frame.size.height + headerContainer.frame.origin.y) - 20);
                }
            }
            
            else {
                if (scrollView.contentOffset.y <= headerContainer.frame.size.height && scrollView.contentOffset.y >= 0) {
                    headerContainer.frame = CGRectMake(0, -1*scrollView.contentOffset.y, headerContainer.frame.size.width, headerContainer.frame.size.height);
                    scrollView.frame = CGRectMake(0, headerContainer.frame.origin.y + headerContainer.frame.size.height, scrollView.frame.size.width,[[UIScreen mainScreen] bounds].size.height - (headerContainer.frame.size.height + headerContainer.frame.origin.y) - 20);
                    frontPageLastLocation = scrollView.contentOffset.y;
                }
                else if (scrollView.contentOffset.y < 0) {
                    headerContainer.frame = CGRectMake(0, 0, headerContainer.frame.size.width, headerContainer.frame.size.height);
                    scrollView.frame = CGRectMake(0, headerContainer.frame.origin.y + headerContainer.frame.size.height, scrollView.frame.size.width,[[UIScreen mainScreen] bounds].size.height - headerContainer.frame.size.height - 20);
                }
            }
            
        }
        
    }
    
    else if (scrollView == commentsTable) {
        // The same functionality for commentsTable
        [self scrollCommentsToHideWithScrollView:commentsTable];
    }
}

// This method handles the hiding header bar on commentsTable scroll
// - it checks contentOffset and moves the header bar up/down and
// - resizes the tableview accordingly.
-(void)scrollCommentsToHideWithScrollView:(UIScrollView *)scrollView {
    if (commentsLastLocation < scrollView.contentOffset.y) {
        scrollDirection = scrollDirectionUp;
    }
    else {
        scrollDirection = scrollDirectionDown;
    }
    
    if (scrollDirection == scrollDirectionUp) {
        if (scrollView.contentSize.height >= [[UIScreen mainScreen] bounds].size.height) {
            if (scrollView.contentOffset.y <= headerContainer.frame.size.height) {
                headerContainer.frame = CGRectMake(0, -1*scrollView.contentOffset.y, headerContainer.frame.size.width, headerContainer.frame.size.height);
                commentsView.frame = CGRectMake(0, headerContainer.frame.origin.y + headerContainer.frame.size.height, commentsView.frame.size.width,[[UIScreen mainScreen] bounds].size.height - (headerContainer.frame.size.height + headerContainer.frame.origin.y) - 20);
                commentsLastLocation = scrollView.contentOffset.y;
            }
            // This just ensures you can't fast-scroll, keeping the header off-screen
            // if the contentOffset is > header.height
            else if (scrollView.contentOffset.y > headerContainer.frame.size.height && (headerContainer.frame.origin.y != (-1*headerContainer.frame.size.height))) {
                headerContainer.frame = CGRectMake(0, -1*headerContainer.frame.size.height, headerContainer.frame.size.width, headerContainer.frame.size.height);
                commentsView.frame = CGRectMake(0, headerContainer.frame.origin.y + headerContainer.frame.size.height, commentsView.frame.size.width,[[UIScreen mainScreen] bounds].size.height - (headerContainer.frame.size.height + headerContainer.frame.origin.y) - 20);
            }
        }
    }
    
    else {
        if (scrollView.contentOffset.y <= headerContainer.frame.size.height && scrollView.contentOffset.y >= 0) {
            headerContainer.frame = CGRectMake(0, -1*scrollView.contentOffset.y, headerContainer.frame.size.width, headerContainer.frame.size.height);
            commentsView.frame = CGRectMake(0, headerContainer.frame.origin.y + headerContainer.frame.size.height, commentsView.frame.size.width,[[UIScreen mainScreen] bounds].size.height - (headerContainer.frame.size.height + headerContainer.frame.origin.y) - 20);
            commentsLastLocation = scrollView.contentOffset.y;
        }
        else if (scrollView.contentOffset.y < 0) {
            headerContainer.frame = CGRectMake(0, 0, headerContainer.frame.size.width, headerContainer.frame.size.height);
            commentsView.frame = CGRectMake(0, headerContainer.frame.origin.y + headerContainer.frame.size.height, commentsView.frame.size.width,[[UIScreen mainScreen] bounds].size.height - headerContainer.frame.size.height - 20);
        }
    }

}
#pragma mark ScrollToTop Management

-(void)setScrollViewToScrollToTop:(UIScrollView*)scrollView{

    externalLinkWebView.scrollView.scrollsToTop = NO;
    commentsTable.scrollsToTop = NO;
    linkWebView.scrollView.scrollsToTop = NO;
    frontPageTable.scrollsToTop = NO;

    scrollView.scrollsToTop = YES;
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
        
        if (homePagePosts.count > 0) {
            // There are Stories/Links to Display, set Post
            Post *post = [homePagePosts objectAtIndex:indexPath.row];
            
            // Set data
            cell.titleLabel.text = post.Title;
            cell.postedTimeLabel.text = [NSString stringWithFormat:@"%@ by %@", [Helpers timeAgoStringForDate:post.TimeCreated], post.Username];
            cell.commentsLabel.text = [NSString stringWithFormat:@"%d", post.CommentCount];
            cell.scoreLabel.text = [NSString stringWithFormat:@"%d Points", post.Points];
            cell.commentTagButton.tag = indexPath.row;
            cell.commentBGButton.tag = indexPath.row;
            [cell.commentTagButton addTarget:self action:@selector(didClickCommentsFromHomepage:) forControlEvents:UIControlEventTouchUpInside];
            [cell.commentBGButton addTarget:self action:@selector(didClickCommentsFromHomepage:) forControlEvents:UIControlEventTouchUpInside];
            
            // If PostActions are visible
            if (post.isOpenForActions) {
                [Helpers makeShadowForView:cell.bottomBar withRadius:0];
                cell.postActionsView.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"PostActions"];
                [cell.voteUpButton addTarget:self action:@selector(voteUp:) forControlEvents:UIControlEventTouchUpInside];
                [cell.voteDownButton addTarget:self action:@selector(voteDown:) forControlEvents:UIControlEventTouchUpInside];
                cell.voteUpButton.tag = indexPath.row;
                cell.voteDownButton.tag = indexPath.row;
                
                if ([HNSingleton sharedHNSingleton].User) {
                    if ([HNSingleton sharedHNSingleton].User.Karma < 500) {
                        [cell.voteDownButton setUserInteractionEnabled:NO];
                        cell.voteDownButton.alpha = 0.3;
                    }
                }
                else {
                    [cell.voteDownButton setUserInteractionEnabled:NO];
                    cell.voteDownButton.alpha = 0.3;
                    [cell.voteUpButton setUserInteractionEnabled:NO];
                    cell.voteUpButton.alpha = 0.3;
                }
            }
            
            // Color cell elements
            cell.titleLabel.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"MainFont"];
            cell.postedTimeLabel.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"SubFont"];
            cell.scoreLabel.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"SubFont"];
            cell.bottomBar.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"BottomBar"];
            [cell.commentTagButton setImage:[[HNSingleton sharedHNSingleton].themeDict objectForKey:@"CommentBubble"] forState:UIControlStateNormal];
            
            // If it's been voted on
            if ([[HNSingleton sharedHNSingleton] objectIsInVoteDict:post]) {
                [cell.scoreLabel setTextColor:kOrangeColor];
                cell.scoreLabel.alpha = 1;
                
                if ([[[[HNSingleton sharedHNSingleton] votedForDictionary] objectForKey:post.PostID] isEqualToString:@"UP"]) {
                    [cell.voteUpButton setImage:[UIImage imageNamed:@"voteUpOn-01.png"] forState:UIControlStateNormal];
                    [cell.voteUpButton setUserInteractionEnabled:NO];
                    [cell.voteDownButton setUserInteractionEnabled:NO];
                }
                else {
                    [cell.voteDownButton setImage:[UIImage imageNamed:@"voteDownOn-01.png"] forState:UIControlStateNormal];
                    [cell.voteUpButton setUserInteractionEnabled:NO];
                    [cell.voteDownButton setUserInteractionEnabled:NO];
                }
            }
            
            // Show HN Color
            if (cell.titleLabel.text.length >= 9) {
                if ([[cell.titleLabel.text substringWithRange:NSMakeRange(0, 9)] isEqualToString:@"Show HN: "]) {
                    UIView *showHNView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
                    showHNView.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"ShowHN"];
                    [cell insertSubview:showHNView atIndex:0];
                }
            }
            
            // Mark as Read
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"MarkAsRead"]) {
                if (post.HasRead) {
                    cell.titleLabel.alpha = 0.35;
                }
            }
            
            // Selected Cell Color
            //UIView *sel = [[UIView alloc] init];
            //sel.backgroundColor = kOrangeColor;
            //cell.selectedBackgroundView = sel;
            
            return cell;
        }
        else {
            // No Links/Stories to Display!
            // Hide cell elements
            cell.bottomBar.alpha = 0;
            cell.authorLabel.alpha = 0;
            cell.scoreLabel.alpha = 0;
            cell.postedTimeLabel.alpha = 0;
            cell.commentBGButton.alpha = 0;
            cell.commentTagButton.alpha = 0;
            cell.commentsLabel.alpha = 0;
            cell.titleLabel.frame = CGRectMake(5, 5, cell.frame.size.width - 10, cell.frame.size.height - 5);
            cell.titleLabel.text = @"";
            cell.titleLabel.textAlignment = NSTextAlignmentCenter;
            return cell;
        }
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
        
        cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
        
        if (organizedCommentsArray.count > 0) {
            // Set Data to UI Elements
            Comment *newComment = [organizedCommentsArray objectAtIndex:indexPath.row];
            cell.commentLevel = newComment.Level;
            cell.holdingView.frame = CGRectMake(15 * newComment.Level, 0, cell.frame.size.width - (15*newComment.Level), cell.frame.size.height);
            cell.username.text = newComment.Username;
            cell.postedTime.text = newComment.TimeAgoString;
            
            // Set Border based on CellType
            if (newComment.CellType == CommentTypeClickClosed) {
                cell.topBarBorder.alpha = 1;
            }
            else if (newComment.CellType == CommentTypeHidden) {
                cell.topBarBorder.alpha = 0;
            }
            else if (newComment.CellType == CommentTypeOpen) {
                cell.topBarBorder.alpha = 0;
                cell.comment.text = newComment.Text;
                
                // Set size of Comment Label
                CGSize s = [cell.comment.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(cell.comment.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
                cell.comment.frame = CGRectMake(cell.comment.frame.origin.x, cell.comment.frame.origin.y, cell.comment.frame.size.width, s.height);
                
                // Add Links
                for (int xx = 0; xx < newComment.Links.count; xx++) {
                    LinkButton *newLinkButton = [LinkButton newLinkButtonWithTag:indexPath.row linkTag:xx frame:CGRectMake(15*newComment.Level + kPad, cell.comment.frame.size.height + cell.comment.frame.origin.y + xx*kPad + xx*30 + kPad, cell.frame.size.width - (15*newComment.Level + 2*kPad), 30) title:newComment.Links[xx]];
                    [newLinkButton addTarget:self action:@selector(didClickExternalLinkInComment:) forControlEvents:UIControlEventTouchUpInside];
                    [cell addSubview:newLinkButton];
                }
            }
            
            // Set action of topBarButton
            cell.topBarButton.tag = indexPath.row;
            [cell.topBarButton addTarget:self action:@selector(hideNestedCommentsCell:) forControlEvents:UIControlEventTouchDownRepeat];
        }
        else if (commentsRefresher.isRefreshing){
            // No comments
            cell.username.text = @"";
            cell.postedTime.text = @"";
            cell.comment.text = @"";
            cell.comment.textAlignment = NSTextAlignmentCenter;
        }
        else{
            cell.username.text = @"";
            cell.postedTime.text = @"";
            cell.comment.text = @"Ahh! Looks like no comments exist!";
            cell.comment.textAlignment = NSTextAlignmentCenter;
        }
        
        // Color cell elements
        cell.comment.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"MainFont"];
        cell.username.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"SubFont"];
        cell.postedTime.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"SubFont"];
        cell.topBar.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"BottomBar"];
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == frontPageTable) {
        // Set Current Post
        currentPost = homePagePosts[indexPath.row];
        
        // Mark As Read
        currentPost.HasRead = YES;
        [[HNSingleton sharedHNSingleton].hasReadThisArticleDict setValue:@"YES" forKey:currentPost.PostID];
        
        // Launch LinkView
        [self launchLinkView];
        
        // Reload table so Mark As Read will show up
        [frontPageTable reloadData];
        
        // Show header if it's offscreen
        [UIView animateWithDuration:0.25 animations:^{
            [self placeHeaderBarBack];
        }];
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
        
        if (organizedCommentsArray.count > 0) {
            Comment *newComment = [organizedCommentsArray objectAtIndex:indexPath.row];
            
            // Comment is Open
            if (newComment.CellType == CommentTypeOpen) {
                CGSize s = [newComment.Text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(cell.comment.frame.size.width - (newComment.Level*15), MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
                
                return s.height + 45 + (newComment.Links.count*30 + newComment.Links.count*kPad);
            }
            
            // Comment has been Clicked Closed by User
            else if (newComment.CellType == CommentTypeClickClosed) {
                return kCommentsHidden;
            }
            
            // Nested comment is hidden
            else if (newComment.CellType == CommentTypeHidden) {
                return 0;
            }
        }
        
        return cell.frame.size.height;
    }
    
    
    // Front Page Cell Height
    else {
        if ([[homePagePosts objectAtIndex:indexPath.row] isOpenForActions]) {
            return kFrontPageActionsHeight;
        }
        return kFrontPageCellHeight;
    }
}

-(void)hideNestedCommentsCell:(UIButton *)commentButton {
    NSMutableArray *rowArray = [@[] mutableCopy];
    Comment *clickComment = organizedCommentsArray[commentButton.tag];
    
    // Close Comment and make hidden all nested Comments
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
    
    // Reload the table with a nice animation
    [commentsTable reloadRowsAtIndexPaths:rowArray withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Table Gesture Recognizers
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

#pragma mark - Front Page Voting Actions
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

#pragma mark - Launch/Hide Comments & Link View
-(void)didClickCommentsFromHomepage:(UIButton *)commentButton {
    currentPost = [homePagePosts objectAtIndex:commentButton.tag];
    [self loadCommentsForPost:currentPost];
    [UIView animateWithDuration:0.25 animations:^{
        [self placeHeaderBarBack];
    }];
}

-(void)launchCommentsView {
    // Scroll to Top
    [commentsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    // Set Post-Title Label
    postTitleLabel.text = currentPost.Title;
    
    // Set frames
    commentsView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - headerContainer.frame.size.height - 20);
    commentsHeader.frame = CGRectMake(0, 0, commentsHeader.frame.size.width, commentsHeader.frame.size.height);
    commentsTable.frame = CGRectMake(0, commentsHeader.frame.size.height, commentsView.frame.size.width, commentsView.frame.size.height - commentsHeader.frame.size.height);
    
    // Add to self.view
    [self.view addSubview:commentsView];
    [self.view bringSubviewToFront:commentsView];
    
    // Animate everything
    [UIView animateWithDuration:0.3 animations:^{
        [frontPageTable setScrollEnabled:NO];
        [frontPageTable setContentOffset:frontPageTable.contentOffset animated:NO];
        headerContainer.frame = CGRectMake(0, 0, headerContainer.frame.size.width, headerContainer.frame.size.height);
        commentsView.frame = CGRectMake(0, headerContainer.frame.size.height, commentsView.frame.size.width, [UIScreen mainScreen].bounds.size.height - headerContainer.frame.size.height - 20);
    } completion:^(BOOL fin){
        [frontPageTable setScrollEnabled:YES];
    }];

    [self setScrollViewToScrollToTop:commentsTable];
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
    if (commentsTable.contentOffset.y < 0  || commentsTable.contentSize.height <= [UIScreen mainScreen].bounds.size.height){
        [commentsTable setContentOffset:CGPointZero animated:NO];
    }
    
    loadingIndicator.alpha = 0;
    [self placeHeaderBarBack];
    
    // Animate everything
    [UIView animateWithDuration:0.3 animations:^{
        commentsView.frame = CGRectMake(0, self.view.frame.size.height, commentsView.frame.size.width, frontPageTable.frame.size.height);
        linkView.frame = CGRectMake(0, self.view.frame.size.height, linkView.frame.size.width, linkView.frame.size.height);
    } completion:^(BOOL fin){
        // Reset header to where it was before clicking Links/Comments
        if (frontPageTable.contentOffset.y >= headerContainer.frame.size.height) {
            [UIView animateWithDuration:0.25 animations:^{
                headerContainer.frame = CGRectMake(0, -1*headerContainer.frame.size.height, headerContainer.frame.size.width, headerContainer.frame.size.height);
                frontPageTable.frame = CGRectMake(0, headerContainer.frame.origin.y + headerContainer.frame.size.height, frontPageTable.frame.size.width,[[UIScreen mainScreen] bounds].size.height - (headerContainer.frame.size.height + headerContainer.frame.origin.y) - 20);
            }];
        }
        else {
            [UIView animateWithDuration:0.25 animations:^{
                headerContainer.frame = CGRectMake(0, -1*frontPageTable.contentOffset.y, headerContainer.frame.size.width, headerContainer.frame.size.height);
                frontPageTable.frame = CGRectMake(0, headerContainer.frame.origin.y + headerContainer.frame.size.height, frontPageTable.frame.size.width,[[UIScreen mainScreen] bounds].size.height - (headerContainer.frame.size.height + headerContainer.frame.origin.y) - 20);
            }];
        }
    }];

    [self setScrollViewToScrollToTop:frontPageTable];
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

// Shows header bar
-(void)placeHeaderBarBack {
    headerContainer.frame = CGRectMake(0, 0, headerContainer.frame.size.width, headerContainer.frame.size.height);
}

- (IBAction)didClickLinkViewFromComments:(id)sender {
    currentPost.HasRead = YES;
    [[HNSingleton sharedHNSingleton].hasReadThisArticleDict setValue:@"YES" forKey:currentPost.PostID];
    [self launchLinkView];
    [frontPageTable reloadData];
}

- (IBAction)didClickCommentsFromLinkView:(id)sender {
    // Drop in Header
    [UIView animateWithDuration:0.25 animations:^{
        headerContainer.frame = CGRectMake(0, 0, headerContainer.frame.size.width, headerContainer.frame.size.height);
        linkView.frame = CGRectMake(0, headerContainer.frame.size.height, linkView.frame.size.width, linkView.frame.size.height);
    }];
    
    // Stop LinkView from Opening/Loading anymore
    linkWebView.delegate = nil;
    [linkWebView stopLoading];
    linkWebView.delegate = self;

    //Empty Current Comments
    organizedCommentsArray = nil;

    //Start Fetching
    [self reloadComments];

    //Reload table to remove old comments

    [commentsTable reloadData];
    
    // Launch the comments
    [self launchCommentsView];
}

-(void)launchLinkView {
    // Stop comments from moving after clicking
    if ([commentsTable isDragging]) {
        [commentsTable setContentOffset:commentsTable.contentOffset animated:NO];
    }
    
    // Drop header back in
    [UIView animateWithDuration:0.25 animations:^{
        headerContainer.frame = CGRectMake(0, 0, headerContainer.frame.size.width, headerContainer.frame.size.height);
        commentsView.frame = CGRectMake(0, headerContainer.frame.size.height, commentsView.frame.size.width, commentsView.frame.size.height);
    }];
    
    // Reset WebView
    [linkWebView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
    
    // Set linkView's frame
    linkView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, [[UIScreen mainScreen] bounds].size.height - headerContainer.frame.size.height - 20);
    linkHeader.frame = CGRectMake(0, 0, linkHeader.frame.size.width, linkHeader.frame.size.height);
    linkWebView.frame = CGRectMake(0, linkHeader.frame.size.height, linkWebView.frame.size.width, linkView.frame.size.height - linkHeader.frame.size.height);
    
    // Add linkView and move to front
    [self.view addSubview:linkView];
    [self.view bringSubviewToFront:linkView];
    
    // Animate it coming in
    [UIView animateWithDuration:0.3 animations:^{
        headerContainer.frame = CGRectMake(0, 0, headerContainer.frame.size.width, headerContainer.frame.size.height);
        linkView.frame = CGRectMake(0, headerContainer.frame.size.height, linkView.frame.size.width, linkView.frame.size.height);
    }];
    
    // Determine if using Readability, and load the webpage
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Readability"]) {
        [linkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.readability.com/m?url=%@", currentPost.URLString]]]];
    }
    else {
        [linkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:currentPost.URLString]]];
    }

    [self setScrollViewToScrollToTop:linkWebView.scrollView];
}


#pragma mark - External Link View
-(void)didClickExternalLinkInComment:(LinkButton *)linkButton {
    Comment *clickComment = organizedCommentsArray[linkButton.tag];
    [self launchExternalLinkViewWithLink:clickComment.Links[linkButton.LinkTag]];
}

-(void)launchExternalLinkViewWithLink:(NSString *)linkString {
    // Set up External Link View
    [externalLinkWebView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
    [externalLinkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:linkString]]];
    
    // Launch Link View
    externalLinkView.frame = CGRectMake(0, self.view.frame.size.height, externalLinkView.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:externalLinkView];
    [UIView animateWithDuration:0.25 animations:^{
        externalLinkView.frame = CGRectMake(0, 0, externalLinkView.frame.size.width, self.view.frame.size.height);
    }];

    [self setScrollViewToScrollToTop:externalLinkWebView.scrollView];
    
}

-(void)hideExternalLinkView {
    [UIView animateWithDuration:0.25 animations:^{
        externalLinkView.frame = CGRectMake(0, self.view.frame.size.height, externalLinkView.frame.size.width, self.view.frame.size.height);
    }];
}

- (IBAction)didClickBackToComments:(id)sender {
    [self hideExternalLinkView];
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
            linkView.frame = CGRectMake(0, headerContainer.frame.origin.y + headerContainer.frame.size.height, linkView.frame.size.width,[[UIScreen mainScreen] bounds].size.height - 20);
        }];
    }
}

@end
