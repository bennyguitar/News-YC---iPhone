//
//  SubmitHNViewController.h
//  HackerNews
//
//  Created by Ben Gordon on 10/22/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SubmitHNType) {
    SubmitHNTypePost,
    SubmitHNTypeComment
};

@interface SubmitHNViewController : UIViewController <UITextFieldDelegate,UITextViewDelegate>

// Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil type:(SubmitHNType)type hnObject:(id)hnObject;

// Actions
- (IBAction)didSelectDoneEditing:(id)sender;

@end
