//
//  HNCommentLink.m
//  libHN-Demo
//
//  Created by Ben Gordon on 10/6/13.
//  Copyright (c) 2013 subvertapps. All rights reserved.
//

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
