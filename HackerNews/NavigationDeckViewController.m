//
//  NavigationDeckViewController.m
//  HackerNews
//
//  Created by Benjamin Gordon on 1/10/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "NavigationDeckViewController.h"

@interface NavigationDeckViewController ()

@end

@implementation NavigationDeckViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Disabling scrollToTop not to interfere with main view's scrollToTop
    [navTable setScrollsToTop:NO];
    
    // Set HeaderBar Color
    //headerBar.backgroundColor = [UIColor colorWithWhite:0.35 alpha:1.0];
    
    // Set Up NotificationCenter
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoginOrOut) name:@"DidLoginOrOut" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard) name:@"HideKeyboard" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggingIn) name:@"LoggingIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boughtPro) name:@"DidPurchasePro" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Did Login Notification
-(void)didLoginOrOut {
    [navTable reloadData];
}

-(void)loggingIn {
    UITableViewCell *cell = [navTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    UIView *blackView = [[UIView alloc] initWithFrame:cell.frame];
    blackView.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.90];
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(blackView.frame.size.width/2 - 12.5, blackView.frame.size.height/2 - 12.5, 25, 25)];
    activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [blackView addSubview:activity];
    [cell addSubview:blackView];
}


#pragma mark - Bought Pro Notification
- (void)boughtPro {
    [navTable reloadData];
}


#pragma mark - Share to Social Delegates
- (void)didClickShareToFacebook {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled) {
                //
            }
            else {
                // It WORKED!
                [self.viewDeckController toggleLeftView];
                [FailedLoadingView launchFailedLoadingInView:self.viewDeckController.centerController.view withImage:[UIImage imageNamed:@"bigCheck-01"] text:@"Successfully shared to Facebook!" duration:1.4];
            }
            
            [controller dismissViewControllerAnimated:YES completion:Nil];
        };
        
        controller.completionHandler =myBlock;
        [controller setInitialText:@"For those on the go, that need to stay in the know: Check out this free HN Reader app. https://itunes.apple.com/us/app/news-yc/id592893508?ls=1&mt=8"];
        [self presentViewController:controller animated:YES completion:Nil];
        
    }
    else{
        // No Facebook Setup
    }
}

- (void)didClickShareToTwitter {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled) {
                //
            }
            else {
                // IT WORKED!
                [self.viewDeckController toggleLeftView];
                [FailedLoadingView launchFailedLoadingInView:self.viewDeckController.centerController.view withImage:[UIImage imageNamed:@"bigCheck-01"] text:@"Successfully shared to Twitter!" duration:1.4];
            }
            
            [controller dismissViewControllerAnimated:YES completion:Nil];
        };
        
        controller.completionHandler = myBlock;
        [controller setInitialText:@"For those on the go, that need to stay in the know: Check out this free HN Reader app. https://itunes.apple.com/us/app/news-yc/id592893508?ls=1&mt=8"];
        [self presentViewController:controller animated:YES completion:Nil];
        
    }
    else{
        // No Twitter Set Up
    }
}


- (void)didClickShareToEmail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"news/YC - The iOS HN Reader"];
        [mailViewController setMessageBody:@"Check out this free HN Reader app for iOS: https://itunes.apple.com/us/app/news-yc/id592893508?ls=1&mt=8" isHTML:NO];
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
    else {
        // No email account
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:^{
        if (result == MFMailComposeResultSent) {
            [self.viewDeckController toggleLeftView];
            [FailedLoadingView launchFailedLoadingInView:self.viewDeckController.centerController.view withImage:[UIImage imageNamed:@"bigCheck-01"] text:@"Successfully shared through Email!" duration:1.4];
        }
    }];
}


#pragma mark - Settings Cell Delegate
- (void)didClickReadability:(BOOL)active {
    // Did change Readablity
    NSNotification *notification = [[NSNotification alloc] initWithName:@"Readability" object:nil userInfo:@{@"Readability":@(active)}];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Readability" object:notification];
}

- (void)didClickMarkAsRead:(BOOL)active {
    //
}

- (void)didClickChangeTheme:(BOOL)nightMode {
    [[HNSingleton sharedHNSingleton] changeTheme];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidChangeTheme" object:nil];
}

#pragma mark - Profile Delegate
- (void)didClickLogout {
    [[HNManager sharedManager] logout];
    [navTable reloadData];
}

- (void)didClickMySubmissions {
    ViewController *vc = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil username:[HNManager sharedManager].SessionUser.Username];
    AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [del.deckController setCenterController:[[UINavigationController alloc] initWithRootViewController:vc]];
    [del.deckController toggleLeftView];
}


#pragma mark - Purchase Pro Delegate
- (void)didSelectPurchasePro {
    GetProViewController *vc = [[GetProViewController alloc] initWithNibName:@"GetProViewController" bundle:nil];
    AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [(UINavigationController *)del.deckController.centerController pushViewController:vc animated:YES];
    [del.deckController toggleLeftView];
}


#pragma mark - Login Delegate
- (void)didClickLoginWithUsername:(NSString *)user password:(NSString *)password {
    [[HNManager sharedManager] loginWithUsername:user password:password completion:^(HNUser *user) {
        [navTable reloadData];
    }];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    ProfileNotLoggedInCell *cell = (ProfileNotLoggedInCell *)[navTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (textField == cell.usernameTextField) {
        [cell.passwordTextField becomeFirstResponder];
    }
    else {
        [cell endEditing:YES];
        [cell didClickLogin];
    }
    
    return YES;
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}


#pragma mark - TableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // FILTER CELL
    if (indexPath.row == [[NSUserDefaults standardUserDefaults] boolForKey:@"Pro"] ? 1 : 0) {
        NSString *CellIdentifier = @"FilterCell";
        FilterCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"FilterCell" owner:nil options:nil];
            for (UIView *view in views) {
                if([view isKindOfClass:[UITableViewCell class]]) {
                    cell = (FilterCell *)view;
                }
            }
        }
        
        [cell setUpCellForActiveFilter];
        
        return cell;
    }
    
    // PROFILE CELL
    else if (indexPath.row == ([[NSUserDefaults standardUserDefaults] boolForKey:@"Pro"] ? 0 : 998)) {
        if ([HNManager sharedManager].SessionUser) {
            NSString *CellIdentifier = @"ProfileCell";
            ProfileLoggedInCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"ProfileLoggedInCell" owner:nil options:nil];
                for (UIView *view in views) {
                    if([view isKindOfClass:[UITableViewCell class]]) {
                        cell = (ProfileLoggedInCell *)view;
                    }
                }
            }
            
            [cell setCellContentWithDelegate:self];
            
            return cell;
        }
        else {
            NSString *CellIdentifier = @"ProfileCell";
            ProfileNotLoggedInCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"ProfileNotLoggedInCell" owner:nil options:nil];
                for (UIView *view in views) {
                    if([view isKindOfClass:[UITableViewCell class]]) {
                        cell = (ProfileNotLoggedInCell *)view;
                    }
                }
            }
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Username"]) {
                cell.usernameTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"Username"];
            }
            
            [cell setActionsAndDelegate:self];
            
            return cell;
        }
    }
    
    else if (indexPath.row == ([[NSUserDefaults standardUserDefaults] boolForKey:@"Pro"] ? 999 : 2)) {
        NSString *CellIdentifier = @"PurchaseCell";
        NavPurchaseProCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"NavPurchaseProCell" owner:nil options:nil];
            for (UIView *view in views) {
                if([view isKindOfClass:[UITableViewCell class]]) {
                    cell = (NavPurchaseProCell *)view;
                }
            }
        }
        
        [cell setContentAndDelegate:self];
        
        return cell;
    }

    // SHARE CELL
    else if (indexPath.row == 3) {
        NSString *CellIdentifier = @"ShareCell";
        ShareCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"ShareCell" owner:nil options:nil];
            for (UIView *view in views) {
                if([view isKindOfClass:[UITableViewCell class]]) {
                    cell = (ShareCell *)view;
                }
            }
        }
        
        [cell setActionsForDelegate:self];
        
        return cell;
    }
    
    // SETTINGS CELL
    else if (indexPath.row == ([[NSUserDefaults standardUserDefaults] boolForKey:@"Pro"] ? 2 : 1)) {
        NSString *CellIdentifier = @"SettingsCell";
        SettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"SettingsCell" owner:nil options:nil];
            for (UIView *view in views) {
                if([view isKindOfClass:[UITableViewCell class]]) {
                    cell = (SettingsCell *)view;
                }
            }
        }

        [cell addActionsToDelegate:self];
        
        return cell;
    }
    
    // CREDITS CELL
    else if (indexPath.row == 4) {
        NSString *CellIdentifier = @"CreditsCell";
        CreditsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"CreditsCell" owner:nil options:nil];
            for (UIView *view in views) {
                if([view isKindOfClass:[UITableViewCell class]]) {
                    cell = (CreditsCell *)view;
                }
            }
        }

        return cell;
    }

    return nil;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [[NSUserDefaults standardUserDefaults] boolForKey:@"Pro"] ? 1 : 0) {
        return kFilterCellHeight;
    }
    else if (indexPath.row == ([[NSUserDefaults standardUserDefaults] boolForKey:@"Pro"] ? 0 : 998)) {
        if ([HNManager sharedManager].SessionUser.Username) {
            return kCellProfLoggedInHeight;
        }
        return kCellProfNotLoggedInHeight;
    }
    else if (indexPath.row == ([[NSUserDefaults standardUserDefaults] boolForKey:@"Pro"] ? 2 : 1)) {
        return kCellSettingsHeight;
    }
    else if (indexPath.row == ([[NSUserDefaults standardUserDefaults] boolForKey:@"Pro"] ? 998 : 2)) {
        return kPurchaseProHeight;
    }
    else if (indexPath.row == 3) {
        return kCellShareHeight;
    }
    else {
        return kCellCreditsHeight;
    }
}



@end
