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
	
    // Set Up Work
    homePagePosts = @[];
    frontPageLastLocation = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI
-(void)buildUI {
    // Header Triangle
    headerTriangle.color = [UIColor colorWithWhite:0.17 alpha:1.0];
    [headerTriangle drawTriangleAtXPosition:self.view.frame.size.width/2];
    
    // Sizes
    headerContainer.frame = CGRectMake(0, 0, headerContainer.frame.size.width, headerContainer.frame.size.height);
    frontPageTable.frame = CGRectMake(0, headerContainer.frame.size.height, frontPageTable.frame.size.width, [[UIScreen mainScreen] bounds].size.height - headerContainer.frame.size.height - 20);
    
    // Add Refresh Controls
    //Add Refresh Controls
    frontPageRefresher = [[UIRefreshControl alloc] init];
    [frontPageRefresher addTarget:self action:@selector(loadHomepage) forControlEvents:UIControlEventValueChanged];
    frontPageRefresher.tintColor = [UIColor blackColor];
    frontPageRefresher.alpha = 0.38;
    [frontPageTable addSubview:frontPageRefresher];
    
    commentsRefresher = [[UIRefreshControl alloc] init];
    [commentsRefresher addTarget:self action:@selector(loadCommentsForPost:) forControlEvents:UIControlEventValueChanged];
    commentsRefresher.tintColor = [UIColor blackColor];
    commentsRefresher.alpha = 0.38;
    [commentsTable addSubview:commentsRefresher];
    
    NSArray *sArray = @[commentsHeader, headerContainer, linkHeader];
    for (UIView *view in sArray) {
        [Helpers makeShadowForView:view withRadius:0];
    }
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
    }
    
    // Stop Activity Indicators
    loadingIndicator.alpha = 0;
    [frontPageRefresher endRefreshing];
}

#pragma mark - Load Comments
-(void)loadCommentsForPost:(Post *)post {
    Webservice *service = [[Webservice alloc] init];
    service.delegate = self;
    [service getCommentsForPost:post];
}

-(void)didFetchComments:(NSArray *)comments {
    if (comments) {
        
    }
    else {
        // No comments were retrieved. Handle exception.
    }
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
    /*
    else if (scrollView == commentsTable) {
        [self scrollCommentsToHideWithScrollView:commentsTable];
    }
     */
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
    /*
    else {
        if (organizedCommentsArray.count > 0) {
            return organizedCommentsArray.count;
        }
        else {
            return 1;
        }
    }
     */
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
            // We have Stories/Links to Display
            Post *post = [homePagePosts objectAtIndex:indexPath.row];
            
            
            cell.titleLabel.text = post.Title;
            //cell.postedTimeLabel.text = [NSString stringWithFormat:@"%@ by %@", [postDict objectForKey:@"time"], [postDict objectForKey:@"user"]];
            cell.postedTimeLabel.text = post.Username;
            cell.commentsLabel.text = [NSString stringWithFormat:@"%d", post.CommentCount];
            cell.scoreLabel.text = [NSString stringWithFormat:@"%d Points", post.Points];
            cell.commentTagButton.tag = indexPath.row;
            cell.commentBGButton.tag = indexPath.row;
            [cell.commentTagButton addTarget:self action:@selector(goToCommentsFromFrontPage:) forControlEvents:UIControlEventTouchUpInside];
            [cell.commentBGButton addTarget:self action:@selector(goToCommentsFromFrontPage:) forControlEvents:UIControlEventTouchUpInside];
            
            
            // COLOR
            cell.titleLabel.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"MainFont"];
            cell.postedTimeLabel.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"SubFont"];
            cell.scoreLabel.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"SubFont"];
            cell.bottomBar.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"BottomBar"];
            [cell.commentTagButton setImage:[[HNSingleton sharedHNSingleton].themeDict objectForKey:@"CommentBubble"] forState:UIControlStateNormal];
            //cell.commentsLabel.textColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"MainFont"];
            
            if (cell.titleLabel.text.length >= 9) {
                if ([[cell.titleLabel.text substringWithRange:NSMakeRange(0, 9)] isEqualToString:@"Show HN: "]) {
                    UIView *showHNView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
                    showHNView.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"ShowHN"];
                    [cell insertSubview:showHNView atIndex:0];
                }
            }
            
            /*
            if (!([postDict objectForKey:@"user"])) {
                UIView *showHNView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
                showHNView.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"HNJobs"];
                [cell insertSubview:showHNView atIndex:0];
                [showHNView release];
                cell.postedTimeLabel.text = [NSString stringWithFormat:@"%@", [postDict objectForKey:@"time"]];
                cell.scoreLabel.text = @"HN Jobs";
                cell.commentTagButton.alpha = 0;
            }
            */
            
            /*
            // Mark as Read
            if ([postDict valueForKey:@"HasRead"]) {
                cell.titleLabel.alpha = 0.35;
            }
            */
            
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
    
    /*
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
            HackerComment *newComment = [organizedCommentsArray objectAtIndex:indexPath.row];
            cell.commentLevel = newComment.commentLevel;
            cell.holdingView.frame = CGRectMake(15 * newComment.commentLevel, 0, cell.frame.size.width - (15*newComment.commentLevel), cell.frame.size.height);
            cell.username.text = newComment.username;
            cell.postedTime.text = newComment.time;
            
            cell.comment.text = [self replaceAllTheBullShit:newComment.comment];
            
            CGSize s = [cell.comment.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(cell.comment.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
            cell.comment.frame = CGRectMake(cell.comment.frame.origin.x, cell.comment.frame.origin.y, cell.comment.frame.size.width, s.height);
        }
        else {
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
     */
}


@end
