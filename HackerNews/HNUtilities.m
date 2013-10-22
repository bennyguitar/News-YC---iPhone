//
//  HNUtilities.m
//  libHN-Demo
//
//  Created by Ben Gordon on 10/6/13.
//  Copyright (c) 2013 subvertapps. All rights reserved.
//

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
