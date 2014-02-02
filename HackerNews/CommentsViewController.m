//
//  CommentsViewController.m
//  HackerNews
//
//  Created by Ben Gordon on 10/22/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "CommentsViewController.h"
#import "LinksViewController.h"
#import "SubmitHNViewController.h"
#import "HNTheme.h"
#import "KGStatusBar.h"
#import "Helpers.h"
#import <BGUtilities.h>

@interface CommentsViewController ()

@property (nonatomic, retain) NSMutableArray *Comments;
@property (nonatomic, retain) HNPost *Post;
@property (strong, nonatomic) IBOutlet UIView *LoadingCommentsView;
@property (weak, nonatomic) IBOutlet UITableView *CommentsTableView;
@property (nonatomic, retain) UIRefreshControl *refreshControl;
@property (nonatomic, retain) NSNumber *AuxiliaryClickIndex;
@property (nonatomic, retain) NSMutableDictionary *CommentCellHeightDictionary;
@property (nonatomic, retain) NSIndexPath *rotateTableIndex;

@end

@implementation CommentsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil post:(HNPost *)post
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.Post = post;
        self.Comments = [NSMutableArray array];
        self.AuxiliaryClickIndex = nil;
        self.rotateTableIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.AuxiliaryClickIndex = nil;
    
    [self buildUI];
    [self loadComments];
    
    // Set Up NotificationCenter
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeTheme) name:@"DidChangeTheme" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addSubmittedCommentNotification:) name:@"DidSubmitNewComment" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadComments) name:@"DidPurchasePro" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buildNavBar) name:@"DidLoginOrOut" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.CommentsTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[HNManager sharedManager] cancelAllRequests];
}

- (void)viewDidDisappear:(BOOL)animated {
    //self.Comments = nil;
    [[HNManager sharedManager] cancelAllRequests];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - UI
- (void)buildUI {
    // Build Nav
    [self buildNavBar];
    
    // Set TableView and LoadingView
    self.CommentsTableView.alpha = 0;
    
    // Color
    [self colorUI];
    
    // Refresh Control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefreshTable) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tintColor = [UIColor blackColor];
    self.refreshControl.alpha = 0.65;
    [self.CommentsTableView addSubview:self.refreshControl];
}

- (void)buildNavBar {
    // Set Up NavBar Actions/Images
    BOOL userIsLoggedIn = [[HNManager sharedManager] userIsLoggedIn];
    BOOL postHasLink = self.Post ? (self.Post.UrlString ? YES : NO) : NO;
    NSMutableArray *rightImages = [NSMutableArray array];
    NSMutableArray *rightActions = [NSMutableArray array];
    if (userIsLoggedIn) {
        [rightImages addObject:[UIImage imageNamed:@"comment_button-01"]];
        [rightActions addObject:@"didClickSubmitComment"];
    }
    if (postHasLink) {
        [rightImages addObject:[UIImage imageNamed:@"goToLink-01"]];
        [rightActions addObject:@"goToLink"];
    }
    
    // Create buttons/actions
    [Helpers buildNavigationController:self leftImage:NO rightImages:rightImages rightActions:rightActions];
    
    // Add Upvote if Necessary
    if (self.Post.UpvoteURLAddition && [[HNManager sharedManager] userIsLoggedIn] && ![[HNManager sharedManager] hasVotedOnObject:self.Post]) {
        [Helpers addUpvoteButtonToNavigationController:self action:@selector(upvoteCurrentPost)];
    }
}

- (void)colorUI {
    // Color
    self.CommentsTableView.backgroundColor = [HNTheme colorForElement:@"CellBG"];
    self.view.backgroundColor = [HNTheme colorForElement:@"CellBG"];
}


#pragma mark - Autoresizing
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self buildNavBar];
    
    // Reload cells on screen
    [self.CommentsTableView reloadRowsAtIndexPaths:[self.CommentsTableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    // Scroll to cell that was at the top before rotation
    [self.CommentsTableView scrollToRowAtIndexPath:self.rotateTableIndex atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    // Save the indexPath of the cell at the top of the screen
    // prior to rotating the view
    CGPoint rotateScrollOffset = self.CommentsTableView.contentOffset;
    self.rotateTableIndex = [self.CommentsTableView indexPathForRowAtPoint:rotateScrollOffset];
}


#pragma mark - Change Theme from Left Menue
- (void)didChangeTheme {
    self.CommentsTableView.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        [self colorUI];
    } completion:^(BOOL fin){
        [self.CommentsTableView reloadData];
        [UIView animateWithDuration:0.2 animations:^{
            self.CommentsTableView.alpha = 1;
        }];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Add Submitted Comment
- (void)addSubmittedCommentNotification:(NSNotification *)notification {
    int index = 0;
    if (notification.userInfo[@"Index"]) {
        index = [notification.userInfo[@"Index"] intValue] + 1;
    }
    else {
        if (self.Post.Type == PostTypeAskHN) {
            index = 1;
        }
    }
    
    if (index <= self.Comments.count) {
        [self.Comments insertObject:notification.userInfo[@"Comment"] atIndex:index];
        [self.CommentsTableView reloadData];
    }
}


#pragma mark - Submit Comment
- (void)didClickSubmitComment {
    SubmitHNViewController *vc = [[SubmitHNViewController alloc] initWithNibName:@"SubmitHNViewController" bundle:nil type:SubmitHNTypeComment hnObject:self.Post commentIndex:nil];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Go to Link
- (void)goToLink {
    if (self.Post && self.Post.UrlString) {
        LinksViewController *vc = [[LinksViewController alloc] initWithNibName:@"LinksViewController" bundle:nil url:[NSURL URLWithString:self.Post.UrlString] post:self.Post];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - WebService
- (void)loadComments {
    if (self.Post) {
        // Show Indicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        // Load Comments
        [[HNManager sharedManager] loadCommentsFromPost:self.Post completion:^(NSArray *comments) {
            if (comments) {
                self.Comments = [comments mutableCopy];
            }
            
            [self refreshTable:self.CommentsTableView];
        }];
    }
}


#pragma mark - Refresh Table
- (void)refreshTable:(UITableView *)tableView {
    [tableView reloadData];
    [self.refreshControl endRefreshing];
    self.LoadingCommentsView.alpha = 0;
    self.CommentsTableView.alpha = 1;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


- (void)pullToRefreshTable {
    [self.refreshControl beginRefreshing];
    [self loadComments];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return a "No Comments Exist" cell
    return self.Comments.count > 0 ? self.Comments.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"CommentCell %d", indexPath.row];
    CommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"CommentsCell" owner:nil options:nil];
        for (UIView *view in views) {
            if([view isKindOfClass:[UITableViewCell class]]) {
                cell = (CommentsCell *)view;
            }
        }
    }
    
    // Set Content
    
    cell = [cell cellForComment:(self.Comments.count > 0 ? self.Comments[indexPath.row] : nil) atIndex:indexPath fromController:self postOP:self.Post.Username showAuxiliary:(self.AuxiliaryClickIndex && (indexPath.row == [self.AuxiliaryClickIndex intValue]) ? YES : NO)];
    [cell.comment setDelegate:self];
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL auxiliary = self.AuxiliaryClickIndex && (indexPath.row == [self.AuxiliaryClickIndex intValue]);
    HNComment *comment = indexPath.row < self.Comments.count ? self.Comments[indexPath.row] : nil;
    float cellHeight = [CommentsCell heightForComment:comment isAuxiliary:auxiliary];
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *oldIndexPath;
    if (self.AuxiliaryClickIndex) {
        int oldIndex = self.AuxiliaryClickIndex.intValue;
        oldIndexPath = [NSIndexPath indexPathForRow:oldIndex inSection:0];
        if (indexPath.row == oldIndex) {
            self.AuxiliaryClickIndex = nil;
        }
        else {
            self.AuxiliaryClickIndex = @(indexPath.row);
        }
    }
    else {
        self.AuxiliaryClickIndex = @(indexPath.row);
    }
    
    NSArray *indexPathsToReload = (oldIndexPath && (oldIndexPath.row != indexPath.row)) ? @[indexPath,oldIndexPath] : @[indexPath];
    [self.CommentsTableView reloadRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    // Load HN Links in CommentController
    if ([url.absoluteString contains:@"https://news.ycombinator.com/item?id="]) {
        NSScanner *scanner = [NSScanner scannerWithString:url.absoluteString];
        NSString *newPostId = @"";
        [scanner scanBetweenString:@"item?id=" andString:@"/" intoString:&newPostId];
        HNPost *newPost = [HNPost new];
        newPost.PostId = newPostId;
        CommentsViewController *newCommentsVC = [[CommentsViewController alloc] initWithNibName:@"CommentsViewController" bundle:nil post:newPost];
        [self.navigationController pushViewController:newCommentsVC animated:YES];
    }
    
    // Load in LinksViewController
    else {
        LinksViewController *vc = [[LinksViewController alloc] initWithNibName:@"LinksViewController" bundle:nil url:url post:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - Comment Cell Delegate
- (void)didClickReplyToCommentAtIndex:(int)index {
    SubmitHNViewController *vc = [[SubmitHNViewController alloc] initWithNibName:@"SubmitHNViewController" bundle:nil type:SubmitHNTypeComment hnObject:self.Comments[index] commentIndex:@(index)];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didClickShareCommentAtIndex:(int)index {
    HNComment *shareComment = self.Comments[index];
    NSMutableString *shareString = [@"" mutableCopy];
    [shareString appendFormat:@"%@:\n%@\n\nhttps://news.ycombinator.com/item?id=%@", shareComment.Username, shareComment.Text, shareComment.CommentId];
    NSArray *activityItems = @[shareString];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)didClickUpvoteCommentAtIndex:(int)index {
    [self voteOnComment:self.Comments[index] direction:VoteDirectionUp];
}

- (void)didClickDownvoteCommentAtIndex:(int)index {
    [self voteOnComment:self.Comments[index] direction:VoteDirectionDown];
}

- (void)voteOnComment:(HNComment *)comment direction:(VoteDirection)direction {
    [[HNManager sharedManager] voteOnPostOrComment:comment direction:direction completion:^(BOOL success) {
        if (success) {
            [KGStatusBar showWithStatus:@"Voting Success"];
            [[HNManager sharedManager] addHNObjectToVotedOnDictionary:comment direction:direction];
        }
        else {
            [KGStatusBar showWithStatus:@"Failed Voting"];
        }
    }];
}

@end
