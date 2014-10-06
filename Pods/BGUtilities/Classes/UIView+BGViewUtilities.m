// Copyright (C) 2013 by Benjamin Gordon
//
// Permission is hereby granted, free of charge, to any
// person obtaining a copy of this software and
// associated documentation files (the "Software"), to
// deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge,
// publish, distribute, sublicense, and/or sell copies of the
// Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall
// be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "UIView+BGViewUtilities.h"

@implementation UIView (BGViewUtilities)

#pragma mark - Separator UIView
+ (UIView *)separatorWithWidth:(float)width origin:(CGPoint)origin color:(UIColor *)color {
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(origin.x, origin.y, width, 1)];
    [separator setBackgroundColor:(color ? color : [UIColor blackColor])];
    [separator setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth];
    return separator;
}


#pragma mark - Shadows
- (void)addShadow {
    [self addShadowWithOffsetSize:CGSizeMake(1.0, 1.0) color:[UIColor blackColor] opacity:0.5 radius:0.0];
}

- (void)addShadowWithOffsetSize:(CGSize)offset color:(UIColor *)color opacity:(float)opacity radius:(float)radius {
    self.layer.shadowColor = color ? color.CGColor : [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = opacity ? opacity : 0.5;
    self.layer.shadowOffset = offset.height ? offset : CGSizeMake(1.0, 1.0);
    self.layer.shadowRadius = radius ? radius : 0;
    self.layer.masksToBounds = NO;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius];
    self.layer.shadowPath = path.CGPath;
}


#pragma mark - Borders
- (void)addBorderWithWidth:(float)width color:(UIColor *)color {
    self.layer.borderWidth = width ? width : 1.0;
    self.layer.borderColor = color ? color.CGColor : [UIColor blackColor].CGColor;
}


#pragma mark - Corner Radius
- (void)setCornerRadius:(float)radius {
    self.layer.cornerRadius = radius ? radius : 0.0;
}


#pragma mark - CGRect & CGSize
- (CGPoint)origin {
    return self.frame.origin;
}

- (float)width {
    return self.frame.size.width;
}

- (float)height {
    return self.frame.size.height;
}

- (float)xOrigin {
    return self.frame.origin.x;
}

- (float)yOrigin {
    return self.frame.origin.y;
}


#pragma mark - Fading Animations
// Main Fade Method
+ (void)fadeViews:(NSArray *)views withDuration:(float)duration fadeIn:(BOOL)fadeIn completion:(void (^)(BOOL finished))completion {
    // If no views, stop the exception
    if (!views) {
        return;
    }
    
    [UIView animateWithDuration:(duration ? duration : 0.25) animations:^{
        [views enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [(UIView *)obj setAlpha:(fadeIn ? 1.0 : 0.0)];
        }];
    } completion:^(BOOL finished){
        if (completion) {
            completion(YES);
        }
    }];
}

// Fade In
- (void)fadeIn {
    [self fadeInWithDuration:0.25 completion:nil];
}

- (void)fadeInWithCompletion:(void (^)(BOOL finished))completion {
    [self fadeInWithDuration:0.25 completion:completion];
}

- (void)fadeInWithDuration:(float)duration {
    [self fadeInWithDuration:duration completion:nil];
}

- (void)fadeInWithDuration:(float)duration completion:(void (^)(BOOL finished))completion {
    [UIView fadeViews:@[self] withDuration:duration fadeIn:YES completion:completion];
}

// Fade Out
- (void)fadeOut {
    [self fadeOutWithDuration:0.25 completion:nil];
}

- (void)fadeOutWithCompletion:(void (^)(BOOL finished))completion {
    [self fadeOutWithDuration:0.25 completion:completion];
}

- (void)fadeOutWithDuration:(float)duration {
    [self fadeOutWithDuration:duration completion:nil];
}

- (void)fadeOutWithDuration:(float)duration completion:(void (^)(BOOL finished))completion {
    [UIView fadeViews:@[self] withDuration:duration fadeIn:NO completion:completion];
}


#pragma mark - Gradient
- (void)addLinearGradientWithStartColor:(UIColor *)startColor endColor:(UIColor *)endColor {
    [self addLinearGradientWithColors:@[startColor,endColor]];
}

- (void)addLinearGradientWithColors:(NSArray *)colors {
    [self addLinearGradientWithColors:colors subLayerIndex:0];
}

- (void)addLinearGradientWithColors:(NSArray *)colors subLayerIndex:(int)index {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    NSMutableArray *gColors = [NSMutableArray array];
    [colors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIColor class]]) {
            [gColors addObject:(id)[obj CGColor]];
        }
    }];
    gradient.colors = gColors;
    gradient.frame = self.bounds;
    int mIndex = self.layer.sublayers.count > index ? index : (int)self.layer.sublayers.count;
    [self.layer insertSublayer:gradient atIndex:mIndex];
}


@end
