//
//  GetProViewController.m
//  HackerNews
//
//  Created by Ben Gordon on 10/24/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "GetProViewController.h"
#import <SatelliteStore.h>
#import "Helpers.h"
#import "HNTheme.h"
#import "KGStatusBar.h"
#import "IIViewDeckController.h"

@interface GetProViewController ()

@property (nonatomic, retain) SatelliteStore *HNStore;
@property (nonatomic, retain) NSArray  *HNProducts;

// UI
@property (weak, nonatomic) IBOutlet UIButton *PurchaseProButton;
@property (weak, nonatomic) IBOutlet UIButton *RestoreProButton;
@property (weak, nonatomic) IBOutlet UITextView *ProTextView;
@property (strong, nonatomic) IBOutlet UIView *ThanksForPurchasingView;

@end

@implementation GetProViewController

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
    
    // Build UI
    [self buildUI];
    
    // Register for Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheme) name:@"DidChangeTheme" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Autoresizing
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self buildNavBar];
}

#pragma mark - UI
- (void)buildUI {
    // Build Nav
    [self buildNavBar];
    
    // Color
    [self colorUI];
}

- (void)buildNavBar {
    [Helpers buildNavigationController:self leftImage:NO rightImages:nil rightActions:nil];
}

- (void)colorUI {
    self.view.backgroundColor = [HNTheme colorForElement:@"CellBG"];
    self.ProTextView.backgroundColor = [HNTheme colorForElement:@"BottomBar"];
    self.ProTextView.textColor = [HNTheme colorForElement:@"MainFont"];
    [self.ProTextView setAttributedText:[self attributedProString]];
    self.ThanksForPurchasingView.backgroundColor = [HNTheme colorForElement:@"CellBG"];
}

- (void)changeTheme {
    self.ProTextView.alpha = 0;
    [self colorUI];
    [UIView animateWithDuration:0.2 animations:^{
        self.ProTextView.alpha = 1;
    }];
}


#pragma mark - Set Attributed Text
- (NSAttributedString *)attributedProString {
    NSMutableAttributedString *proString = [[NSMutableAttributedString alloc] initWithString:@"Because who likes just reading HackerNews? Why not contribute to the community?\n\nWith a purchase of the pro version of this app you get a lot of things:\n\nLogin and view your submissions.\nSubmit a link or a self-post.\nReply to any post or comment.\nVote on posts or comments.\n\nAs I add more features in the future, you'll be able to do all of that as well. Purchasing the pro version also has a positive effect on me maintaining this app and maintaining the GitHub repository for it as well (oh yeah, it's totally open-sourced too).\n\nThanks for purchasing pro, and I really hope you like it!"];
    
    // Background Color
    [proString addAttribute:NSBackgroundColorAttributeName value:[HNTheme colorForElement:@"BottomBar"] range:NSMakeRange(0, proString.string.length)];
    
    // Font Color
    [proString addAttribute:NSForegroundColorAttributeName value:[HNTheme colorForElement:@"MainFont"] range:NSMakeRange(0, proString.string.length)];
    
    // Font
    [proString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, proString.string.length)];
    
    // Set Bold Text
    [proString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:[proString.string rangeOfString:@"HackerNews"]];
    [proString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:[proString.string rangeOfString:@"Login and view your submissions."]];
    [proString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:[proString.string rangeOfString:@"Submit a link or a self-post."]];
    [proString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:[proString.string rangeOfString:@"Reply to any post or comment."]];
    [proString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:[proString.string rangeOfString:@"Vote on posts or comments."]];
    [proString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:[proString.string rangeOfString:@"Thanks for purchasing pro, and I really hope you like it!"]];
    
    return proString;
}


#pragma mark - Satellite Store
- (void)purchasePro {
    if ([[SatelliteStore shoppingCenter] Inventory]) {
        [[SatelliteStore shoppingCenter] purchaseProductWithIdentifier:kProProductID withCompletion:^(BOOL purchased) {
            [self setUIForPurchase:purchased];
        }];
    }
    else {
        [[SatelliteStore shoppingCenter] getProductsWithCompletion:^(BOOL success) {
            if (success) {
                // Try again
                [self purchasePro];
            }
        }];
    }
}

- (void)restorePro {
    [[SatelliteStore shoppingCenter] restorePurchasesWithCompletion:^(BOOL purchased) {
        [self setUIForPurchase:purchased];
    }];
}

- (void)setUIForPurchase:(BOOL)purchased {
    if (purchased) {
        self.ThanksForPurchasingView.alpha = 0;
        self.ThanksForPurchasingView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [self.view addSubview:self.ThanksForPurchasingView];
        [UIView animateWithDuration:0.25 animations:^{
            self.ThanksForPurchasingView.alpha = 1;
        }];
        [KGStatusBar showWithStatus:@"Upgraded to Pro"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Pro"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidPurchasePro" object:nil];
        [self.viewDeckController toggleLeftView];
    }
    else {
        [KGStatusBar showWithStatus:@"Failed to purchase. Try again."];
    }
}


#pragma mark - Actions
- (IBAction)didClickPurchasePro:(id)sender {
    [self purchasePro];
}

- (IBAction)didClickRestorePro:(id)sender {
    [self restorePro];
}

@end
