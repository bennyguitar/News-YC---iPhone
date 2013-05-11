//
//  SubmitLinkViewController.h
//  HackerNews
//
//  Created by Benjamin Gordon on 5/11/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Webservice.h"
#import "HNSingleton.h"
#import "Helpers.h"

@interface SubmitLinkViewController : UIViewController <WebserviceDelegate,UITextFieldDelegate,UITextViewDelegate>

@end
