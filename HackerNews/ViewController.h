//
//  ViewController.h
//  HackerNews
//
//  Created by Benjamin Gordon on 5/1/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Webservice.h"
#import "TriangleView.h"
#import "HNSingleton.h"
#import "frontPageCell.h"
#import "CommentsCell.h"
#import "Helpers.h"
#import "LinkButton.h"
#import "IIViewDeckController.h"
#import "FailedLoadingView.h"
#import "ARChromeActivity.h"
#import "TUSafariActivity.h"
#import "UILabel+LinkDetection.h"

#define kPad 10

#define kLoadingRectNoSubmit CGRectMake(291,17,20,20)
#define kLoadingRectSubmit CGRectMake(249,17,20,20)

@interface ViewController : UIViewController <WebserviceDelegate, UITableViewDataSource, UITableViewDelegate,UIWebViewDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate>

@end
