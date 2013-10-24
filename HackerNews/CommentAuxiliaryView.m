//
//  CommentAuxiliaryView.m
//  HackerNews
//
//  Created by Ben Gordon on 10/23/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "CommentAuxiliaryView.h"

@implementation CommentAuxiliaryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (CommentAuxiliaryView *)auxiliaryViewWithFrame:(CGRect)frame {
    // Load from Nib
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"CommentAuxiliaryView" owner:nil options:nil];
    CommentAuxiliaryView *view = [[CommentAuxiliaryView alloc] init];
    view = [views objectAtIndex:0];
    
    view.frame = frame;
    
    // Return
    return view;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
