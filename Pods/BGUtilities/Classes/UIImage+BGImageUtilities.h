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

@interface UIImage (BGImageUtilities)

#pragma mark - Image With New Color
/**
 *  Creates a new UIImage from another UIImage by replacing all alpha != 0 pixels with the passed in UIColor.
 *
 *  @param replaceColor UIColor
 *
 *  @return UIImage
 */
- (instancetype)imageWithNewColor:(UIColor *)replaceColor;


#pragma mark - Image By Replacing Color
/**
 *  Creates a new UIImage from another UIImage by replacing all instances of one color with another.
 *
 *  @param badColor     UIColor
 *  @param replaceColor UIColor
 *
 *  @return UIImage
 */
- (instancetype)imageByReplacingColor:(UIColor *)badColor withColor:(UIColor *)replaceColor;


#pragma mark - Image By Replacing Colors close to another Color
/**
 *  Creates a new UIImage from another UIImage by replacing all colors that are close to another color with a replacement color.
 *
 *  @param distance     CGFloat
 *  @param badColor     UIColor
 *  @param replaceColor UIColor
 *
 *  @return UIImage
 */
- (instancetype)imageByReplacingColorsWithinDistance:(CGFloat)distance fromColor:(UIColor *)badColor withColor:(UIColor *)replaceColor;

@end
