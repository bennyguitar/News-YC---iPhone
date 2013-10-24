//
//  CommentAuxiliaryView.h
//  HackerNews
//
//  Created by Ben Gordon on 10/23/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentAuxiliaryView : UIView

@property (weak, nonatomic) IBOutlet UIButton *auxiliaryShareButton;
@property (weak, nonatomic) IBOutlet UIButton *auxiliaryCommentButton;
@property (weak, nonatomic) IBOutlet UIButton *auxiliaryUpvoteButton;
@property (weak, nonatomic) IBOutlet UIButton *auxiliaryDownvoteButton;
@property (weak, nonatomic) IBOutlet UIView *auxiliarySeparator;


+ (CommentAuxiliaryView *)auxiliaryViewWithFrame:(CGRect)frame;

@end
