//
//  SubmitHNViewController.m
//  HackerNews
//
//  Created by Ben Gordon on 10/22/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "Helpers.h"
#import "SubmitHNViewController.h"

@interface SubmitHNViewController ()

@property (nonatomic, assign) id HNObject;
@property (nonatomic, assign) SubmitHNType SubmitType;

@end

@implementation SubmitHNViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil type:(SubmitHNType)type hnObject:(id)hnObject
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.SubmitType = type;
        self.HNObject = hnObject;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Build Nav
    [Helpers buildNavigationController:self leftImage:NO rightImage:nil rightAction:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
