//
//  LinksViewController.h
//  HackerNews
//
//  Created by Ben Gordon on 10/22/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HNManager.h"

@interface LinksViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, readonly, retain) HNPost *Post;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSURL *)url post:(HNPost *)post;

@end
