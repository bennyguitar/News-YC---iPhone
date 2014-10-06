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

#import <UIKit/UIKit.h>

@interface UIView (BGViewUtilities)

#pragma mark - Separator UIView
/**
 Creates a 1 pixel tall separtor of any color you'd like. The returned separator can stretch its width, but cannot stretch its height on rotation or resizing.
 @param width   - width of the returned separator
 @param origin  - CGPoint of the x,y coordinates ot begin
 @param color   - UIColor for the separator
 @return UIView - returns the view with the correct frame.
 */
+ (UIView *)separatorWithWidth:(float)width origin:(CGPoint)origin color:(UIColor *)color;


#pragma mark - Shadows
/**
 Creates a generic shadow on the view. This calls the following method: [self addShadowWithOffsetSize:CGSizeMake(1.0, 1.0) color:[UIColor blackColor] opacity:0.5 radius:0.0].
 */
- (void)addShadow;

/**
 Creates and adds a shadow to any UIView.
 @param offset  - CGSize for shadow offset. Positive x goes right, positive y goes down.
 @param color   - UIColor for the shadow color
 @param opacity - float for the shadow opacity
 @param radius  - float for shadow corner radius
 */
- (void)addShadowWithOffsetSize:(CGSize)offset color:(UIColor *)color opacity:(float)opacity radius:(float)radius;


#pragma mark - Borders
/**
 Creates and adds a border to any UIView. The border is inset - meaning the frame size stays the same, the border just takes up the innermost width parameter of the perimeter of the UIView.
 @param width   - float for number of pixels
 @param color   - UIColor
 */
- (void)addBorderWithWidth:(float)width color:(UIColor *)color;


#pragma mark - Corner Radius
/**
 This is a shorthand method to change the cornerRadius on a UIView's layer property.
 @param radius  - float for corner radius
 */
- (void)setCornerRadius:(float)radius;


#pragma mark - CGRect & CGSize
/**
 This is a shorthand method to get the origin.
 @returns CGPoint
 */
- (CGPoint)origin;

/**
 This is a shorthand method to get the width of the frame.
 @returns float
 */
- (float)width;

/**
 This is a shorthand method to get the height of the frame.
 @returns CGPoint
 */
- (float)height;

/**
 This is a shorthand method to get the X Origin of the frame.
 @returns float
 */
- (float)xOrigin;

/**
 This is a shorthand method to get the Y Origin of the frame.
 @returns float
 */
- (float)yOrigin;


#pragma mark - Animations
/**
 This animates the UIView fading in.
 @param duration   - The duration in seconds of the fade.
 */
- (void)fadeInWithDuration:(float)duration;

/**
 This animates the UIView fading in.
 @param duration   - The duration in seconds of the fade.
 @param completion - A block to run after the animation is finished
 */
- (void)fadeInWithDuration:(float)duration completion:(void (^)(BOOL finished))completion;

/**
 This animates the UIView fading in with a duration of 0.25.
 */
- (void)fadeIn;

/**
 This animates the UIView fading in with a duration of 0.25.
 @param completion - A block to run after the animation is finished
 */
- (void)fadeInWithCompletion:(void (^)(BOOL finished))completion;

/**
 This animates the UIView fading in.
 @param duration   - The duration in seconds of the fade.
 */
- (void)fadeOutWithDuration:(float)duration;

/**
 This animates the UIView fading in.
 @param duration   - The duration in seconds of the fade.
 @param completion - A block to run after the animation is finished
 */
- (void)fadeOutWithDuration:(float)duration completion:(void (^)(BOOL finished))completion;

/**
 This animates the UIView fading in with a duration of 0.25.
 */
- (void)fadeOut;

/**
 This animates the UIView fading in with a duration of 0.25.
 @param completion - A block to run after the animation is finished
 */
- (void)fadeOutWithCompletion:(void (^)(BOOL finished))completion;

/**
 This is the ultimate fading animation method. It takes in an array of UIViews, the duration, whether to fade in or not, and a completion block to run after the animation is finished.
 @param views      - NSArray of UIViews
 @param duration   - The duration in seconds of the fade.
 @param fadeIn     - YES to fade in, NO to fade out
 @param completion - A block to run after the animation is finished
 */
+ (void)fadeViews:(NSArray *)views withDuration:(float)duration fadeIn:(BOOL)fadeIn completion:(void (^)(BOOL finished))completion;


#pragma mark - Gradient
/**
 *  Creates a linear gradient from top to bottom, where the startColor is the top and the endColor is the bottom. There is no gradient pivot between colors, it is a smooth transition from start to end.
 *
 *  @param startColor UIColor
 *  @param endColor   UIColor
 */
- (void)addLinearGradientWithStartColor:(UIColor *)startColor endColor:(UIColor *)endColor;

/**
 *  Creates a linear gradient from top to bottom, where the color at [colors firstObject] is at the top of the view, and the color at [colors lastObject] is at the bottom. Each color is split evenly across the gradient - there is no pivot point between colors.
 *
 *  @param colors NSArray of UIColors
 */
- (void)addLinearGradientWithColors:(NSArray *)colors;

/**
 *  Creates a linear gradient from top to bottom, where the color at [colors firstObject] is at the top of the view, and the color at [colors lastObject] is at the bottom. Each color is split evenly across the gradient - there is no pivot point between colors. This method places the gradient at a specific sublayer.
 *
 *  @param colors NSArray of UIColors
 */
- (void)addLinearGradientWithColors:(NSArray *)colors subLayerIndex:(int)index;


@end
