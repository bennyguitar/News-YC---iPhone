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
    // Do any additional setup after loading the view from its nib.
    
    [self buildUI];
}

-(void)buildUI {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)changeTypeToTop:(id)sender {
    FilterCell *cell = (FilterCell *)[navTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.filterTopButton setBackgroundColor:[UIColor colorWithRed:200/255.0f green:97/255.0f blue:41/255.0f alpha:1.0]];
    [cell.filterNewButton setBackgroundColor:[UIColor colorWithWhite:0.85 alpha:1.0]];
    [cell.filterAskButton setBackgroundColor:[UIColor colorWithWhite:0.85 alpha:1.0]];
    ViewController *vc = [[ViewController alloc] initWithNibName:@"ViewController" bundle:[NSBundle mainBundle]];
    [HNSingleton sharedHNSingleton].filter = fTypeTop;
    self.viewDeckController.centerController = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.viewDeckController toggleLeftView];
}

- (IBAction)changeTypeToNew:(id)sender {
    FilterCell *cell = (FilterCell *)[navTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.filterNewButton setBackgroundColor:[UIColor colorWithRed:200/255.0f green:97/255.0f blue:41/255.0f alpha:1.0]];
    [cell.filterTopButton setBackgroundColor:[UIColor colorWithWhite:0.85 alpha:1.0]];
    [cell.filterAskButton setBackgroundColor:[UIColor colorWithWhite:0.85 alpha:1.0]];
    ViewController *vc = [[ViewController alloc] initWithNibName:@"ViewController" bundle:[NSBundle mainBundle]];
    [HNSingleton sharedHNSingleton].filter = fTypeNew;
    self.viewDeckController.centerController = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.viewDeckController toggleLeftView];
}

- (IBAction)changeTypeToAsk:(id)sender {
    FilterCell *cell = (FilterCell *)[navTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.filterTopButton setBackgroundColor:[UIColor colorWithWhite:0.85 alpha:1.0]];
    [cell.filterNewButton setBackgroundColor:[UIColor colorWithWhite:0.85 alpha:1.0]];
    [cell.filterAskButton setBackgroundColor:[UIColor colorWithRed:200/255.0f green:97/255.0f blue:41/255.0f alpha:1.0]];
    ViewController *vc = [[ViewController alloc] initWithNibName:@"ViewController" bundle:[NSBundle mainBundle]];
    [HNSingleton sharedHNSingleton].filter = fTypeAsk;
    self.viewDeckController.centerController = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.viewDeckController toggleLeftView];
}

- (IBAction)didClickShareToFacebook:(id)sender {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled) {
                //
            }
            else {
                // It WORKED!
                ShareCell *cell = (ShareCell *)[navTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                cell.checkImage.alpha = 1;
                [UIView animateWithDuration:1.5 animations:^{
                    cell.checkImage.alpha = 0;
                }];
            }
            
            [controller dismissViewControllerAnimated:YES completion:Nil];
        };
        
        controller.completionHandler =myBlock;
        [controller setInitialText:@"For those on the go, that need to stay in the know: Check out this free HN Reader app. https://itunes.apple.com/us/app/news-yc/id592893508?ls=1&mt=8"];
        [self presentViewController:controller animated:YES completion:Nil];
        
    }
    else{
        // No Facebook Setup
        errorLabel.text = @"No Facebook account!";
        errorLabel.alpha = 1;
        [UIView animateWithDuration:1.5 animations:^{
            errorLabel.alpha = 0;
        }];
    }
}

- (IBAction)didClickShareToTwitter:(id)sender {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled) {
                //
            }
            else {
                // IT WORKED!
                ShareCell *cell = (ShareCell *)[navTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                cell.checkImage.alpha = 1;
                [UIView animateWithDuration:1.5 animations:^{
                    cell.checkImage.alpha = 0;
                }];
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

- (IBAction)didClickShareToEmail:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"news/YC - The iOS HN Reader"];
        [mailViewController setMessageBody:@"Check out this free HN Reader app for iOS: https://itunes.apple.com/us/app/news-yc/id592893508?ls=1&mt=8" isHTML:NO];
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
    else {
        errorLabel.text = @"No Email account!";
        errorLabel.alpha = 1;
        [UIView animateWithDuration:1.5 animations:^{
            errorLabel.alpha = 0;
        }];
    }
}

#pragma mark - Readability
-(void)didClickReadability {
    SettingsCell *cell = (SettingsCell *)[navTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    if (cell.readabilityLabel.text.length == 18) {
        [cell.readabilityButton setImage:[UIImage imageNamed:@"nav_readability_on-01.png"] forState:UIControlStateNormal];
        cell.readabilityButton.alpha = 1;
        cell.readabilityLabel.text = @"Readability is ON";
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Readability"];
    }
    else {
        [cell.readabilityButton setImage:[UIImage imageNamed:@"nav_readability_off-01.png"] forState:UIControlStateNormal];
        cell.readabilityButton.alpha = 0.5;
        cell.readabilityLabel.text = @"Readability is OFF";
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Readability"];
    }
    
}

#pragma mark - Mark As Read
-(void)didClickMarkAsRead {
    SettingsCell *cell = (SettingsCell *)[navTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    if (cell.markAsReadLabel.text.length == 19) {
        [cell.markAsReadButton setImage:[UIImage imageNamed:@"nav_markasread_on-01.png"] forState:UIControlStateNormal];
        cell.markAsReadButton.alpha = 1;
        cell.markAsReadLabel.text = @"Mark as Read is ON";
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MarkAsRead"];
    }
    else {
        [cell.markAsReadButton setImage:[UIImage imageNamed:@"nav_markasread_off-01.png"] forState:UIControlStateNormal];
        cell.markAsReadButton.alpha = 0.5;
        cell.markAsReadLabel.text = @"Mark as Read is OFF";
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MarkAsRead"];
    }
    
}


#pragma mark - Theme Change
-(void)didClickChangeTheme {
    SettingsCell *cell = (SettingsCell *)[navTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    if (cell.themeLabel.text.length == 14) {
        [cell.nightModeButton setImage:[UIImage imageNamed:@"nav_daymode_on-01.png"] forState:UIControlStateNormal];
        cell.nightModeButton.alpha = 1;
        cell.themeLabel.text = @"Theme is DAY";
        [[NSUserDefaults standardUserDefaults] setValue:@"Day" forKey:@"Theme"];
    }
    else {
        [cell.nightModeButton setImage:[UIImage imageNamed:@"nav_nightmode_on-01.png"] forState:UIControlStateNormal];
        cell.nightModeButton.alpha = 1;
        cell.themeLabel.text = @"Theme is NIGHT";
        [[NSUserDefaults standardUserDefaults] setValue:@"Night" forKey:@"Theme"];
    }
    
    [[HNSingleton sharedHNSingleton] changeTheme];
    ViewController *vc = [[ViewController alloc] initWithNibName:@"ViewController" bundle:[NSBundle mainBundle]];
    self.viewDeckController.centerController = [[UINavigationController alloc] initWithRootViewController:vc];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:^{
        if (result == MFMailComposeResultSent) {
            ShareCell *cell = (ShareCell *)[navTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
            cell.checkImage.alpha = 1;
            [UIView animateWithDuration:1.5 animations:^{
                cell.checkImage.alpha = 0;
            }];
        }
    }];
}



#pragma mark - TableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        // FILTER CELL
        
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
        [cell.filterTopButton addTarget:self action:@selector(changeTypeToTop:) forControlEvents:UIControlEventTouchUpInside];
        [cell.filterNewButton addTarget:self action:@selector(changeTypeToNew:) forControlEvents:UIControlEventTouchUpInside];
        [cell.filterAskButton addTarget:self action:@selector(changeTypeToAsk:) forControlEvents:UIControlEventTouchUpInside];
        
        // Build UI
        NSArray *bArray = @[cell.filterTopButton,cell.filterNewButton, cell.filterAskButton];
        for (UIButton *b in bArray) {
            b.layer.cornerRadius = 10;
            b.layer.shadowColor = [UIColor blackColor].CGColor;
            b.layer.shadowOpacity = 0.4f;
            b.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
            b.layer.shadowRadius = 2.75f;
            b.layer.masksToBounds = NO;
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:b.bounds cornerRadius:10];
            b.layer.shadowPath = path.CGPath;
        }
        
        cell.filterTopOverlay.layer.cornerRadius = 7;
        cell.filterNewOverlay.layer.cornerRadius = 7;
        cell.filterAskOverlay.layer.cornerRadius = 7;
        
        return cell;
    }
    
    
    // SHARE CELL
    else if (indexPath.row == 2) {
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
        [cell.fbButton addTarget:self action:@selector(didClickShareToFacebook:) forControlEvents:UIControlEventTouchUpInside];
        [cell.twitterButton addTarget:self action:@selector(didClickShareToTwitter:) forControlEvents:UIControlEventTouchUpInside];
        [cell.emailButton addTarget:self action:@selector(didClickShareToEmail:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    
    // SETTINGS CELL
    else if (indexPath.row == 1) {
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

        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Readability"]) {
            [cell.readabilityButton setImage:[UIImage imageNamed:@"nav_readability_on-01.png"] forState:UIControlStateNormal];
            cell.readabilityButton.alpha = 1;
            cell.readabilityLabel.text = @"Readability is ON";
        }
        else {
            [cell.readabilityButton setImage:[UIImage imageNamed:@"nav_readability_off-01.png"] forState:UIControlStateNormal];
            cell.readabilityButton.alpha = 0.5;
            cell.readabilityLabel.text = @"Readability is OFF";
        }
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"MarkAsRead"]) {
            [cell.markAsReadButton setImage:[UIImage imageNamed:@"nav_markasread_on-01.png"] forState:UIControlStateNormal];
            cell.markAsReadButton.alpha = 1;
            cell.markAsReadLabel.text = @"Mark as Read is ON";
        }
        else {
            [cell.markAsReadButton setImage:[UIImage imageNamed:@"nav_markasread_off-01.png"] forState:UIControlStateNormal];
            cell.markAsReadButton.alpha = 0.5;
            cell.markAsReadLabel.text = @"Mark as Read is OFF";
        }
        
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"Theme"] isEqualToString:@"Night"]) {
            [cell.nightModeButton setImage:[UIImage imageNamed:@"nav_nightmode_on-01.png"] forState:UIControlStateNormal];
            cell.nightModeButton.alpha = 1;
            cell.themeLabel.text = @"Theme is NIGHT";
        }
        else {
            [cell.nightModeButton setImage:[UIImage imageNamed:@"nav_daymode_on-01.png"] forState:UIControlStateNormal];
            cell.nightModeButton.alpha = 1;
            cell.themeLabel.text = @"Theme is DAY";
        }
        
        [cell.readabilityButton addTarget:self action:@selector(didClickReadability) forControlEvents:UIControlEventTouchUpInside];
        [cell.readabilityHidden addTarget:self action:@selector(didClickReadability) forControlEvents:UIControlEventTouchUpInside];
        [cell.markAsReadButton addTarget:self action:@selector(didClickMarkAsRead) forControlEvents:UIControlEventTouchUpInside];
        [cell.markAsReadHidden addTarget:self action:@selector(didClickMarkAsRead) forControlEvents:UIControlEventTouchUpInside];
        [cell.nightModeButton addTarget:self action:@selector(didClickChangeTheme) forControlEvents:UIControlEventTouchUpInside];
        [cell.themeHidden addTarget:self action:@selector(didClickChangeTheme) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    
    // SHARE CELL
    else if (indexPath.row == 3) {
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

}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 102;
    }
    else if (indexPath.row == 2) {
        return 112;
    }
    else if (indexPath.row == 1) {
        return 180;
    }
    else {
        return 151;
    }
}



@end
