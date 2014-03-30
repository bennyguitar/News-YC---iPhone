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

#import "UIImage+BGImageUtilities.h"
#import "Colours.h"

@implementation UIImage (BGImageUtilities)

#pragma mark - Image With New Color
- (instancetype)imageWithNewColor:(UIColor *)replaceColor {
    CGRect imageRect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL, imageRect.size.width, imageRect.size.height, 8, imageRect.size.width * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGContextClipToMask(context, imageRect, self.CGImage);
    NSArray *rgba = [replaceColor rgbaArray];
    CGContextSetRGBFillColor(context, [rgba[0] floatValue], [rgba[1] floatValue], [rgba[2] floatValue], [rgba[3] floatValue]);
    CGContextFillRect(context, imageRect);
    
    CGImageRef finalImage = CGBitmapContextCreateImage(context);
    UIImage *returnImage = [UIImage imageWithCGImage:finalImage];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(finalImage);
    
    return returnImage;
}


#pragma mark - Image By Replacing Color
- (instancetype)imageByReplacingColor:(UIColor *)badColor withColor:(UIColor *)replaceColor {
    CGImageRef imageRef = [self CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpace, CGImageGetBitmapInfo(imageRef));
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(bitmapContext, CGRectMake(0, 0, CGBitmapContextGetWidth(bitmapContext),CGBitmapContextGetHeight(bitmapContext)), imageRef);
    UInt8 *data = CGBitmapContextGetData(bitmapContext);
    NSInteger numComponents = 4;
    NSInteger bytesInContext = CGBitmapContextGetHeight(bitmapContext) *
    CGBitmapContextGetBytesPerRow(bitmapContext);
    
    //Get RGB values of fromColor
    NSArray *aRGBA = [badColor rgbaArray];
    NSArray *bRGBA = [replaceColor rgbaArray];
    
    //Now iterate through each pixel in the image..
    double redIn, greenIn, blueIn,alphaIn;
    for (NSInteger i = 0; i < bytesInContext; i += numComponents) {
        //rgba value of current pixel..
        redIn = (double)data[i]/255.0;
        greenIn = (double)data[i+1]/255.0;
        blueIn = (double)data[i+2]/255.0;
        alphaIn = (double)data[i+3]/255.0;
        
        //now you got current pixel rgb values...check it curresponds with your fromColor
        if(redIn == [aRGBA[0] floatValue] && greenIn == [aRGBA[1] floatValue] && blueIn == [aRGBA[2] floatValue]) {
            //image color matches fromColor, then change current pixel color to toColor
            data[i] = [bRGBA[0] floatValue];
            data[i+1] = [bRGBA[1] floatValue];
            data[i+2] = [bRGBA[2] floatValue];
            data[i+3] = [bRGBA[3] floatValue];
        }
    }
    
    CGImageRef outImage = CGBitmapContextCreateImage(bitmapContext);
    UIImage *newImage = [UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    return newImage;
}


#pragma mark - Image By Replacing Colors close to another Color
- (instancetype)imageByReplacingColorsWithinDistance:(CGFloat)distance fromColor:(UIColor *)badColor withColor:(UIColor *)replaceColor {
    CGImageRef imageRef = [self CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpace, CGImageGetBitmapInfo(imageRef));
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(bitmapContext, CGRectMake(0, 0, CGBitmapContextGetWidth(bitmapContext),CGBitmapContextGetHeight(bitmapContext)), imageRef);
    UInt8 *data = CGBitmapContextGetData(bitmapContext);
    NSInteger numComponents = 4;
    NSInteger bytesInContext = CGBitmapContextGetHeight(bitmapContext) *
    CGBitmapContextGetBytesPerRow(bitmapContext);
    
    //Get RGB values of fromColor
    NSArray *bRGBA = [replaceColor rgbaArray];
    
    //Now iterate through each pixel in the image..
    double redIn, greenIn, blueIn, alphaIn;
    for (NSInteger i = 0; i < bytesInContext; i += numComponents) {
        //rgba value of current pixel..
        redIn = (double)data[i]/255.0;
        greenIn = (double)data[i+1]/255.0;
        blueIn = (double)data[i+2]/255.0;
        alphaIn = (double)data[i+3]/255.0;
        UIColor *pixelColor = [UIColor colorWithRed:redIn green:greenIn blue:blueIn alpha:alphaIn];
        if ([pixelColor distanceFromColor:badColor] <= distance) {
            data[i] = [bRGBA[0] floatValue];
            data[i+1] = [bRGBA[1] floatValue];
            data[i+2] = [bRGBA[2] floatValue];
            data[i+3] = [bRGBA[3] floatValue];
        }
    }
    
    CGImageRef outImage = CGBitmapContextCreateImage(bitmapContext);
    UIImage *newImage = [UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    return newImage;
}



@end
