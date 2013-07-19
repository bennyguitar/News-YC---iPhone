//
//  Comment.m
//  HackerNews
//
//  Created by Benjamin Gordon on 5/1/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "Comment.h"
#import "Helpers.h"
#import "Link.h"

@implementation Comment

-(id)init {
    self = [super init];
    if (self) {
        self.Children = [@[] mutableCopy];
        self.Links = [@[] mutableCopy];
        self.Text = @"";
        self.Username = @"";
        self.CommentID = @"";
        self.ParentID = @"";
        self.ReplyURL = @"";
        self.Level = 0;
        self.TimeCreated = [NSDate date];
        self.CellType = CommentTypeOpen;
    }
    return self;
}

+(NSArray *)commentsFromHTML:(NSString *)html {
    // Set Up
    NSMutableArray *comments = [@[] mutableCopy];
    NSString *trash = @"";
    NSArray *htmlComponents = [html componentsSeparatedByString:@"<tr><td><table border=0><tr><td><img src=\"s.gif\""];
    
    for (int xx = 1; xx < htmlComponents.count; xx++) {
        NSScanner *scanner = [NSScanner scannerWithString:htmlComponents[xx]];
        Comment *newComment = [[Comment alloc] init];
        NSString *level = @"";
        NSString *user = @"";
        NSString *text = @"";
        NSString *timeAgo = @"";
        
        // Get Comment Level
        [scanner scanString:@"height=1 width=" intoString:&trash];
        [scanner scanUpToString:@">" intoString:&level];
        newComment.Level = [level intValue] / 40;
        
        // Get Username
        [scanner scanUpToString:@"<a href=\"user?id=" intoString:&trash];
        [scanner scanString:@"<a href=\"user?id=" intoString:&trash];
        [scanner scanUpToString:@"\">" intoString:&user];
        newComment.Username = user.length > 0 ? user : @"[deleted]";
        
        // Get Date/Time Label
        [scanner scanUpToString:@"</a> " intoString:&trash];
        [scanner scanString:@"</a> " intoString:&trash];
        [scanner scanUpToString:@" |" intoString:&timeAgo];
        newComment.TimeAgoString = timeAgo;
        
        // Get Comment Text
        [scanner scanUpToString:@"<font color=" intoString:&trash];
        [scanner scanString:@"<font color=" intoString:&trash];
        [scanner scanUpToString:@">" intoString:&trash];
        [scanner scanString:@">" intoString:&trash];
        [scanner scanUpToString:@"</font>" intoString:&text];
        [newComment setUpComment:text];
        
        // Get Reply URL
        
        // Save Comment
        [comments addObject:newComment];
    }
    
    return comments;
}

-(void)setUpComment:(NSString *)text {
    // Get rid of <html> marks by replacing
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
    text = [text stringByReplacingOccurrencesOfString:@"<pre><code>" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"</code></pre>" withString:@""];
    
    // Get rid of <a> marks
    text = [self removeAHREFFromText:text];
    
    // Set up Attributable String
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setLineBreakMode:NSLineBreakByWordWrapping];
    self.attrText = [[NSMutableAttributedString alloc] initWithString:text];
    [self.attrText addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, text.length)];
    self.Text = text;
    
    // Find the links / add them to attrText and self.Links
    NSDataDetector *detector = [[NSDataDetector alloc] initWithTypes:(NSTextCheckingTypes)NSTextCheckingTypeLink error:nil];
    [detector enumerateMatchesInString:text options:kNilOptions range:NSMakeRange(0, text.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        Link *newLink = [[Link alloc] init];
        newLink.URLRange = result.range;
        newLink.URL = result.URL;
        [self.Links addObject:newLink];
        [self.attrText addAttribute:NSForegroundColorAttributeName value:kOrangeColor range:result.range];
    }];
}

-(NSString *)removeAHREFFromText:(NSString *)text {
    NSScanner *scanner = [NSScanner scannerWithString:text];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];
    NSString *commentText = @"", *runningString = @"", *trash = @"";
    while (![scanner isAtEnd]) {
        if ([[scanner.string substringFromIndex:scanner.scanLocation] rangeOfString:@"<a href"].location != NSNotFound) {
            [scanner scanUpToString:@"<a href=" intoString:&commentText];
            runningString = [runningString stringByAppendingString:commentText];
            [scanner scanString:@"<a href=\"" intoString:&trash];
            [scanner scanUpToString:@"\"" intoString:&commentText];
            runningString = [runningString stringByAppendingString:commentText];
            [scanner scanUpToString:@"</a>" intoString:&trash];
            [scanner scanString:@"</a>" intoString:&trash];
        }
        else {
            runningString = [runningString stringByAppendingString:[scanner.string substringFromIndex:scanner.scanLocation]];
            [scanner setScanLocation:text.length];
        }
    }
    return runningString;
}

@end
