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

#import "HNCommentLink.h"

@implementation HNCommentLink

+ (NSArray *)linksFromCommentText:(NSString *)commentText {
    NSMutableArray *linkArray = [NSMutableArray array];
    NSDataDetector *detector = [[NSDataDetector alloc] initWithTypes:(NSTextCheckingTypes)NSTextCheckingTypeLink error:nil];
    [detector enumerateMatchesInString:commentText options:kNilOptions range:NSMakeRange(0, commentText.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        HNCommentLink *newLink = [[HNCommentLink alloc] init];
        newLink.UrlRange = result.range;
        newLink.Url = result.URL;
        
        // Find out if it's an HN contained link
        if ([newLink.Url.absoluteString rangeOfString:@"news.ycombinator.com/"  ].location != NSNotFound) {
            newLink.Type = LinkTypeHN;
        }
        else {
            newLink.Type = LinkTypeDefault;
        }
        
        // Add it
        [linkArray addObject:newLink];
    }];
    
    // Return the NSArray
    return linkArray;
}

@end
