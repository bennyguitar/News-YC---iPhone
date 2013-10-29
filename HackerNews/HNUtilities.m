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

#import "HNUtilities.h"

@implementation HNUtilities

+ (NSString *)stringByReplacingHTMLEntitiesInText:(NSString *)text {
    text = [text stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n\n"];
    text = [text stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"<i>" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"</i>" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"&#38;" withString:@"&"];
    text = [text stringByReplacingOccurrencesOfString:@"&#62;" withString:@">"];
    text = [text stringByReplacingOccurrencesOfString:@"&#x27;" withString:@"'"];
    text = [text stringByReplacingOccurrencesOfString:@"&#x2F;" withString:@"/"];
    text = [text stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    text = [text stringByReplacingOccurrencesOfString:@"&#60;" withString:@"<"];
    text = [text stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    text = [text stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    text = [text stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    text = [text stringByReplacingOccurrencesOfString:@"<pre><code>" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"</code></pre>" withString:@""];
    
    // Replace <a> tags
    NSScanner *scanner = [NSScanner scannerWithString:text];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];
    NSString *goodText = @"", *runningString = @"", *trash = @"";
    while (![scanner isAtEnd]) {
        if ([[scanner.string substringFromIndex:scanner.scanLocation] rangeOfString:@"<a href"].location != NSNotFound) {
            [scanner scanUpToString:@"<a href=" intoString:&goodText];
            runningString = [runningString stringByAppendingString:goodText];
            [scanner scanString:@"<a href=\"" intoString:&trash];
            [scanner scanUpToString:@"\"" intoString:&goodText];
            runningString = [runningString stringByAppendingString:goodText];
            [scanner scanUpToString:@"</a>" intoString:&trash];
            [scanner scanString:@"</a>" intoString:&trash];
        }
        else {
            runningString = [runningString stringByAppendingString:[scanner.string substringFromIndex:scanner.scanLocation]];
            [scanner setScanLocation:text.length];
        }
    }
    
    // Return it!
    return runningString;
}

@end


@implementation NSScanner (HNScanner)

- (void)scanBetweenString:(NSString *)stringA andString:(NSString *)stringB intoString:(NSString **)passByString {
    NSString *trash = @"";
    [self scanUpToString:stringA intoString:&trash];
    [self scanString:stringA intoString:&trash];
    [self scanUpToString:stringB intoString:passByString];
}

@end


