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

#import "NSScanner+BGScannerUtilities.h"

@implementation NSScanner (BGScannerUtilities)

#pragma mark - Scan Between Strings into a String
- (void)scanBetweenString:(NSString *)stringA andString:(NSString *)stringB intoString:(NSString **)passByRefString {
    NSString *trash = @"";
    [self scanUpToString:stringA intoString:&trash];
    [self scanString:stringA intoString:&trash];
    [self scanUpToString:stringB intoString:passByRefString];
}

#pragma mark - Enumerate the substrings between two strings
- (void)enumerateSubstringsBetweenString:(NSString *)stringA andString:(NSString *)stringB separator:(NSString *)separator block:(void (^)(NSString *subString, NSInteger index, BOOL *stop))enumerationBlock {
    NSString *enumerationString = @"";
    [self scanBetweenString:stringA andString:stringB intoString:&enumerationString];
    
    // Enumerate in Block
    NSInteger index = 0;
    BOOL stop = NO;
    for (NSString *subString in [enumerationString componentsSeparatedByString:separator]) {
        enumerationBlock(subString,index,&stop);
        index++;
        if (stop == YES) {
            break;
        }
    }
}

@end
