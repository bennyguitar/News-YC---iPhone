//
//  CommentsViewController.h
//  HackerNews
//
//  Created by Ben Gordon on 10/22/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "libHN.h"
#import "CommentsCell.h"

@interface CommentsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,TTTAttributedLabelDelegate>

// Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil post:(HNPost *)post;

@end
