//
//  triangleView.h
//  TableBreakOut
//
//  Created by Benjamin Gordon on 10/16/12.
//  Copyright (c) 2012 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface triangleView : UIView

@property (nonatomic, assign) float x;
@property (nonatomic, retain) UIColor *color;

-(void)drawTriangleAtXPosition:(float)xpos;

@end
