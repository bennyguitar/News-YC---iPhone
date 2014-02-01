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

@interface NSScanner (BGScannerUtilities)

#pragma mark - Scan Betwen Strings into a String
/**
 This function scans everything between two NSStrings into another NSString that is passed by reference into the method.
 @param stringA - NSString to start scanning after
 @param stringB - NSString to scan until
 @param passByRefString - NSString that assumes the value of the scan
 */
- (void)scanBetweenString:(NSString *)stringA andString:(NSString *)stringB intoString:(NSString **)passByRefString;


#pragma mark - Enumerate the substrings between two strings
/**
 This function enumerates the substrings delimted by the separator between two strings.
 @param stringA - NSString to start scanning after
 @param stringB - NSString to scan until
 @param separator   - NSString to delimit the substrings
 @param enumerationBlock    - Block to enumerate substrings
 */
- (void)enumerateSubstringsBetweenString:(NSString *)stringA andString:(NSString *)stringB separator:(NSString *)separator block:(void (^)(NSString *subString, NSInteger index, BOOL *stop))enumerationBlock;


@end
