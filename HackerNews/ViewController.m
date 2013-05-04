//
//  ViewController.m
//  HackerNews
//
//  Created by Benjamin Gordon on 5/1/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    [self loadHomepage];
    [self buildUI];
    [self colorUI];
	
    // Set Up Data
    homePagePosts = @[];
    organizedCommentsArray = @[];
    frontPageLastLocation = 0;
    commentsLastLocation = 0;
    
    // Set Up NotificationCenter
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeTheme) name:@"DidChangeTheme" object:nil];
}

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
    self.view.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"CellBG"];
    frontPageTable.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"CellBG"];
    frontPageTable.separatorColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"Separator"];
    commentsTable.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"CellBG"];
    
    underHeaderTriangle.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"TableTriangle"];
    headerTriangle.color = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"TableTriangle"];
    [headerTriangle drawTriangleAtXPosition:self.view.frame.size.width/2];
    
    [self.view setNeedsDisplay];
}

-(void)didChangeTheme {
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


#pragma mark - Load HomePage
-(void)loadHomepage {
    Webservice *service = [[Webservice alloc] init];
    service.delegate = self;
    [service getHomepage];
    loadingIndicator.alpha = 1;
}

-(void)didFetchPosts:(NSArray *)posts {
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
    Webservice *service = [[Webservice alloc] init];
    service.delegate = self;
    [service getCommentsForPost:post launchComments:YES];
    currentPost = post;
    loadingIndicator.alpha = 1;
}

-(void)reloadComments {
    Webservice *service = [[Webservice alloc] init];
    service.delegate = self;
    [service getCommentsForPost:currentPost launchComments:NO];
    [commentsRefresher beginRefreshing];
    loadingIndicator.alpha = 1;
}

-(void)didFetchComments:(NSArray *)comments forPostID:(NSString *)postID launchComments:(BOOL)launch {
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

#pragma mark - Scroll View Delegate
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
        [self scrollCommentsToHideWithScrollView:commentsTable];
    }
}

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


#pragma mark - TableView Delegate
-(int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == frontPageTable) {
        if (homePagePosts.count == 0) {
            return 1;
        }
        return homePagePosts.count - 1;
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
            // There are Stories/Links to Display
            Post *post = [homePagePosts objectAtIndex:indexPath.row];
            cell.titleLabel.text = post.Title;
            cell.postedTimeLabel.text = [NSString stringWithFormat:@"%@ by %@", [Helpers timeAgoStringForDate:post.TimeCreated], post.Username];
            cell.commentsLabel.text = [NSString stringWithFormat:@"%d", post.CommentCount];
            cell.scoreLabel.text = [NSString stringWithFormat:@"%d Points", post.Points];
            cell.commentTagButton.tag = indexPath.row;
            cell.commentBGButton.tag = indexPath.row;
            [cell.commentTagButton addTarget:self action:@selector(didClickCommentsFromHomepage:) forControlEvents:UIControlEventTouchUpInside];
            [cell.commentBGButton addTarget:self action:@selector(didClickCommentsFromHomepage:) forControlEvents:UIControlEventTouchUpInside];
            
            
            // COLOR
            cell.titleLabel.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"MainFont"];
            cell.postedTimeLabel.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"SubFont"];
            cell.scoreLabel.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"SubFont"];
            cell.bottomBar.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"BottomBar"];
            [cell.commentTagButton setImage:[[HNSingleton sharedHNSingleton].themeDict objectForKey:@"CommentBubble"] forState:UIControlStateNormal];
            
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
            UIView *bgView = [[UIView alloc] init];
            [bgView setBackgroundColor:[UIColor colorWithRed:(122/255.0) green:(59/255.0) blue:(26/255.0) alpha:0.6]];
            [cell setSelectedBackgroundView:bgView];
            
            return cell;
        }
        else {
            // No Links/Stories to Display!
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
                if([view isKindOfClass:[UITableViewCell class]])
                {
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
            cell.postedTime.text = [Helpers timeAgoStringForDate:newComment.TimeCreated];
            
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
        else {
            // No comments
            cell.username.text = @"";
            cell.postedTime.text = @"";
            cell.comment.text = @"Ahh! Looks like no comments exist!";
            cell.comment.textAlignment = NSTextAlignmentCenter;
        }
        
        // COLOR
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
                if([view isKindOfClass:[UITableViewCell class]])
                {
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
        return frontPageTable.rowHeight;
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
    
    [commentsTable reloadRowsAtIndexPaths:rowArray withRowAnimation:UITableViewRowAnimationFade];
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
    
    commentsView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - headerContainer.frame.size.height - 20);
    commentsHeader.frame = CGRectMake(0, 0, commentsHeader.frame.size.width, commentsHeader.frame.size.height);
    commentsTable.frame = CGRectMake(0, commentsHeader.frame.size.height, commentsView.frame.size.width, commentsView.frame.size.height - commentsHeader.frame.size.height);
    [self.view addSubview:commentsView];
    [self.view bringSubviewToFront:commentsView];
    [UIView animateWithDuration:0.3 animations:^{
        [frontPageTable setScrollEnabled:NO];
        [frontPageTable setContentOffset:frontPageTable.contentOffset animated:NO];
        headerContainer.frame = CGRectMake(0, 0, headerContainer.frame.size.width, headerContainer.frame.size.height);
        commentsView.frame = CGRectMake(0, headerContainer.frame.size.height, commentsView.frame.size.width, [UIScreen mainScreen].bounds.size.height - headerContainer.frame.size.height - 20);
    } completion:^(BOOL fin){
        [frontPageTable setScrollEnabled:YES];
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
    if (commentsTable.contentOffset.y < 0  || commentsTable.contentSize.height <= [UIScreen mainScreen].bounds.size.height){
        [commentsTable setContentOffset:CGPointZero animated:NO];
    }
    
    loadingIndicator.alpha = 0;
    [self placeHeaderBarBack];
    [UIView animateWithDuration:0.3 animations:^{
        commentsView.frame = CGRectMake(0, self.view.frame.size.height, commentsView.frame.size.width, frontPageTable.frame.size.height);
        linkView.frame = CGRectMake(0, self.view.frame.size.height, linkView.frame.size.width, linkView.frame.size.height);
    } completion:^(BOOL fin){
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
}

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
    
    // Launch the comments
    [self launchCommentsView];
}

-(void)launchLinkView {
    if ([commentsTable isDragging]) {
        [commentsTable setContentOffset:commentsTable.contentOffset animated:NO];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        headerContainer.frame = CGRectMake(0, 0, headerContainer.frame.size.width, headerContainer.frame.size.height);
        commentsView.frame = CGRectMake(0, headerContainer.frame.size.height, commentsView.frame.size.width, commentsView.frame.size.height);
    }];
    
    // Reset WebView
    [linkWebView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
    
    // Open that sucka'
    linkView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, [[UIScreen mainScreen] bounds].size.height - headerContainer.frame.size.height - 20);
    linkHeader.frame = CGRectMake(0, 0, linkHeader.frame.size.width, linkHeader.frame.size.height);
    linkWebView.frame = CGRectMake(0, linkHeader.frame.size.height, linkWebView.frame.size.width, linkView.frame.size.height - linkHeader.frame.size.height);
    [self.view addSubview:linkView];
    [self.view bringSubviewToFront:linkView];
    [UIView animateWithDuration:0.3 animations:^{
        headerContainer.frame = CGRectMake(0, 0, headerContainer.frame.size.width, headerContainer.frame.size.height);
        linkView.frame = CGRectMake(0, headerContainer.frame.size.height, linkView.frame.size.width, linkView.frame.size.height);
    }];
    
    // Determine if using Readability
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Readability"]) {
        [linkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.readability.com/m?url=%@", currentPost.URLString]]]];
    }
    else {
        [linkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:currentPost.URLString]]];
    }
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
