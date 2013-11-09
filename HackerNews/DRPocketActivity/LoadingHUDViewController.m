//
//  LoadingHUDViewController.m
//  HackerNews
//
//  Created by Daniel Rosado on 09/11/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "LoadingHUDViewController.h"
#import "SVProgressHUD.h"

@implementation LoadingHUDViewController
{
    NSString *_loadingString;
}

- (instancetype)initWithLoadingStatus:(NSString*)string
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _loadingString = string;
    }
    
    return self;
}

- (void)loadView
{
    UIView *vw = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    vw.backgroundColor = [UIColor clearColor];
    self.view = vw;
    
    [SVProgressHUD showWithStatus:_loadingString maskType:SVProgressHUDMaskTypeGradient];
}

@end
