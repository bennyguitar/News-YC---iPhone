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

#import "HNPost.h"
#import "HNUtilities.h"

@implementation HNPost

#pragma mark - Parse Posts
+ (NSArray *)parsedPostsFromHTML:(NSString *)html FNID:(NSString *__autoreleasing *)fnid {
    // Set up
    NSArray *htmlComponents = [html componentsSeparatedByString:@"<td align=\"right\" valign=\"top\" class=\"title\">"];
    NSMutableArray *postArray = [NSMutableArray array];
    
    // Scan through components and build posts
    for (int xx = 1; xx < htmlComponents.count; xx++) {
        // If it's Dead - move past it
        if ([htmlComponents[xx] rangeOfString:@"<td class=\"title\"> [dead] <a"].location != NSNotFound) {
            continue;
        }
        
        // Create new Post
        HNPost *newPost = [[HNPost alloc] init];
        
        // Set Up for Scanning
        NSScanner *scanner = [[NSScanner alloc] initWithString:htmlComponents[xx]];
        NSString *trash = @"";
        NSString *urlString = @"";
        NSString *title = @"";
        NSString *hoursAgo = @"";
        NSString *comments = @"";
        NSString *author = @"";
        NSString *points = @"";
        NSString *postId = @"";
        NSString *upvoteString = @"";
        
        // Scan for Upvotes
        if ([htmlComponents[xx] rangeOfString:@"votearrow"].location != NSNotFound) {
            [scanner scanBetweenString:@"href=\"" andString:@"whence" intoString:&upvoteString];
            newPost.UpvoteURLAddition = upvoteString;
        }
        
        // Scan URL
        [scanner scanBetweenString:@"<a href=\"" andString:@"\"" intoString:&urlString];
        newPost.UrlString = urlString;
        
        // Scan Title
        [scanner scanBetweenString:@">" andString:@"</a>" intoString:&title];
        newPost.Title = title;
        
        // Scan Points
        [scanner scanBetweenString:@"id=\"score_" andString:@">" intoString:&trash];
        [scanner scanBetweenString:@">" andString:@" " intoString:&points];
        newPost.Points = [points intValue];
        
        // Scan Author
        [scanner scanBetweenString:@"<a href=\"user?id=" andString:@"\"" intoString:&author];
        newPost.Username = author;
        
        // Scan Time Ago
        [scanner scanBetweenString:@"</a> <a href=\"" andString:@"\"" intoString:&trash];
        [scanner scanBetweenString:@">" andString:@"ago" intoString:&hoursAgo];
        newPost.TimeCreatedString = [hoursAgo stringByAppendingString:@"ago"];
        
        // Scan Number of Comments
        [scanner scanBetweenString:@"<a href=\"item?id=" andString:@"\">" intoString:&postId];
        [scanner scanBetweenString:@"\">" andString:@"</a>" intoString:&comments];
        newPost.PostId = postId;
        if ([comments isEqualToString:@"discuss"]) {
            newPost.CommentCount = 0;
        }
        else {
            NSScanner *cScan = [[NSScanner alloc] initWithString:comments];
            NSString *cCount = @"";
            [cScan scanUpToString:@" " intoString:&cCount];
            newPost.CommentCount = [cCount intValue];
        }
        
        // Check if Jobs Post
        if (newPost.PostId.length == 0 && newPost.Points == 0 && newPost.Username.length == 0) {
            newPost.Type = PostTypeJobs;
            if ([urlString rangeOfString:@"http"].location == NSNotFound) {
                newPost.PostId = [urlString stringByReplacingOccurrencesOfString:@"item?id=" withString:@""];
            }
        }
        else {
            // Check if AskHN
            if ([urlString rangeOfString:@"http"].location == NSNotFound && newPost.PostId.length > 0) {
                newPost.Type = PostTypeAskHN;
                urlString = [@"https://news.ycombinator.com/" stringByAppendingString:urlString];
            }
            else {
                newPost.Type = PostTypeDefault;
            }
        }
        
        
        // Grab FNID if last
        if (xx == htmlComponents.count - 1) {
            [scanner scanUpToString:@"<td class=\"title\"><a href=\"" intoString:&trash];
            NSString *Fnid = @"";
            [scanner scanString:@"<td class=\"title\"><a href=\"" intoString:&trash];
            [scanner scanUpToString:@"\"" intoString:&Fnid];
            *fnid = [Fnid stringByReplacingOccurrencesOfString:@"/" withString:@""];
            *fnid = [*fnid stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        }
        
        [postArray addObject:newPost];
    }
    
    return postArray;
}

- (NSString *)UrlDomain {
    NSString *urlDomain = nil;
    
    if (self.UrlString) {
        NSURL *url = [NSURL URLWithString:self.UrlString];
        urlDomain = [url host];
        if ([urlDomain hasPrefix:@"www."]) {
            urlDomain = [urlDomain substringFromIndex:4];
        }
    }
    
    return urlDomain;
}

@end
