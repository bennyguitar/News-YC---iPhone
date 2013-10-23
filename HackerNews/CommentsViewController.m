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
#import "HNSingleton.h"
#import "Helpers.h"

@interface CommentsViewController ()

@property (nonatomic, retain) NSArray *Comments;
@property (nonatomic, retain) HNPost *Post;
@property (strong, nonatomic) IBOutlet UIView *LoadingCommentsView;
@property (weak, nonatomic) IBOutlet UITableView *CommentsTableView;
@property (nonatomic, retain) UIRefreshControl *refreshControl;

@end

@implementation CommentsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil post:(HNPost *)post
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.Post = post;
        self.Comments = @[];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self buildUI];
    [self loadComments];
    
    // Set Up NotificationCenter
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeTheme) name:@"DidChangeTheme" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadComments) name:@"DidSubmitNewComment" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    //[self loadComments];
}

#pragma mark - UI
- (void)buildUI {
    // Build Nav
    BOOL userIsLoggedIn = [[HNManager sharedManager] userIsLoggedIn];
    [Helpers buildNavigationController:self leftImage:NO rightImage:(userIsLoggedIn ? [UIImage imageNamed:@"comment_button-01"] : nil) rightAction:(userIsLoggedIn ? @selector(didClickSubmitComment) : nil)];
    
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

- (void)colorUI {
    // Color
    self.CommentsTableView.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"CellBG"];
    self.view.backgroundColor = [[HNSingleton sharedHNSingleton].themeDict objectForKey:@"CellBG"];
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

#pragma mark - Submit Comment
- (void)didClickSubmitComment {
    SubmitHNViewController *vc = [[SubmitHNViewController alloc] initWithNibName:@"SubmitHNViewController" bundle:nil type:SubmitHNTypeComment hnObject:self.Post];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - WebService
- (void)loadComments {
    if (self.Post) {
        // Add Activity Indicator View
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
        [Helpers navigationController:self addActivityIndicator:&indicator];
        
        // Load Comments
        [[HNManager sharedManager] loadCommentsFromPost:self.Post completion:^(NSArray *comments) {
            if (comments) {
                self.Comments = comments;
            }
            
            [self refreshTable:self.CommentsTableView indicator:indicator];
        }];
    }
}


#pragma mark - Refresh Table
- (void)refreshTable:(UITableView *)tableView indicator:(UIActivityIndicatorView *)indicator {
    [tableView reloadData];
    [indicator removeFromSuperview];
    [self.refreshControl endRefreshing];
    self.LoadingCommentsView.alpha = 0;
    self.CommentsTableView.alpha = 1;
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
    
    // Set Content
    cell = [cell cellForComment:(self.Comments.count > 0 ? self.Comments[indexPath.row] : nil) atIndex:indexPath fromController:self];
    [cell.comment setDelegate:self];
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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
    
    return [cell heightForComment:(self.Comments.count > 0 ? self.Comments[indexPath.row] : nil)];
}


#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    LinksViewController *vc = [[LinksViewController alloc] initWithNibName:@"LinksViewController" bundle:nil url:url];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
