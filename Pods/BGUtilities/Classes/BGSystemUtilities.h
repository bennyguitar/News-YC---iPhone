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

#import <Foundation/Foundation.h>

@interface BGSystemUtilities : NSObject

#pragma mark - Screen Width/Height
/**
 Returns the screen width for the current orientation. This method uses the [[UIApplication sharedApplication] statusBarOrientation] method to determine screen width. If you manually override that property, it will cause this method to return the wrong information.
 @returns float
 */
+ (float)screenWidth;

/**
 Returns the screen height for the current orientation. This method uses the [[UIApplication sharedApplication] statusBarOrientation] method to determine screen width. If you manually override that property, it will cause this method to return the wrong information.
 @returns float
 */
+ (float)screenHeight;


#pragma mark - System Version
/**
 Returns the current operating system version.
 @returns float
 */
+ (float)iOSVersion;

@end
