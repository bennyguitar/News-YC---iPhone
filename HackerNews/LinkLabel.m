//
//  LinkLabel.m
//  HackerNews
//
//  Created by Ben Gordon on 9/21/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "LinkLabel.h"
#import "UILabel+LinkDetection.h"

@implementation LinkLabel
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    if ([self.delegate respondsToSelector:@selector(didTapUILabelAtIndex:)]) {
        [self.delegate didTapUILabelAtIndex:[self characterIndexAtPoint:[touch locationInView:self]]];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    if ([self.delegate respondsToSelector:@selector(didTapUILabelAtIndex:)]) {
        [self.delegate didTapUILabelAtIndex:[self characterIndexAtPoint:[touch locationInView:self]]];
    }
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
