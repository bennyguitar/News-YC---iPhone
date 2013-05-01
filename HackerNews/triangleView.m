//
//  triangleView.m
//  TableBreakOut
//
//  Created by Benjamin Gordon on 10/16/12.
//  Copyright (c) 2012 Benjamin Gordon. All rights reserved.
//

#import "triangleView.h"

@implementation triangleView
@synthesize x;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        x = self.frame.size.width/2;
        self.color = [UIColor colorWithWhite:0.17 alpha:1.0];
    }
    return self;
}

-(void)drawTriangleAtXPosition:(float)xpos {
    x = xpos;
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIBezierPath *triangle = [UIBezierPath bezierPath];
    [self.color setFill];
    [triangle moveToPoint:CGPointMake(x - 10, self.frame.size.height)];
    [triangle addLineToPoint:CGPointMake(x, self.frame.size.height - 10)];
    [triangle addLineToPoint:CGPointMake(x + 10, self.frame.size.height)];
    [triangle addLineToPoint:CGPointMake(x - 10, self.frame.size.height)];
    [triangle fill];
}


@end
