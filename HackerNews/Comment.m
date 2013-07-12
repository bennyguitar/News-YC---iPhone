//
//  Comment.m
//  HackerNews
//
//  Created by Benjamin Gordon on 5/1/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "Comment.h"
#import "Helpers.h"

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
        newComment.Username = user;
        
        // Get Date/Time Label
        [scanner scanUpToString:@"</a> " intoString:&trash];
        [scanner scanString:@"</a> " intoString:&trash];
        [scanner scanUpToString:@" |" intoString:&timeAgo];
        newComment.TimeAgoString = timeAgo;
        
        // Get Comment Text
        [scanner scanUpToString:@"<font color=#000000>" intoString:&trash];
        [scanner scanString:@"<font color=#000000>" intoString:&trash];
        [scanner scanUpToString:@"</font>" intoString:&text];
        [newComment setUpComment:text];
        
        // Get Reply URL
        
        // Save Comment
        [comments addObject:newComment];
    }
    
    return comments;
}

+(Comment *)commentFromDictionary:(NSDictionary *)dict {
    Comment *newComment = [[Comment alloc] init];
    
    // Set Data
    newComment.CommentID = [dict objectForKey:@"_id"];
    newComment.hnCommentID = [dict objectForKey:@"id"];
    newComment.ParentID = [dict objectForKey:@"parent_sigid"];
    newComment.Username = [dict objectForKey:@"username"];
    newComment.Level = 0;
    newComment.TimeCreated = [Helpers postDateFromString:[dict objectForKey:@"create_ts"]];
    
    // Check if Text is null - if it is, it will be @""
    if ([dict objectForKey:@"text"] != [NSNull null]) {
        [newComment setUpComment:[dict objectForKey:@"text"]];
    }
    
    return newComment;
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
    [paragraph setLineBreakMode:NSLineBreakByTruncatingTail];
    self.attrText = [[NSMutableAttributedString alloc] initWithString:text];
    [self.attrText addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, text.length)];
    self.Text = text;
    
    
    // Find the links / add them to attrText and self.Links
    NSDataDetector *detector = [[NSDataDetector alloc] initWithTypes:(NSTextCheckingTypes)NSTextCheckingTypeLink error:nil];
    [detector enumerateMatchesInString:text options:kNilOptions range:NSMakeRange(0, text.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSLog(@"%@", result);
        NSLog(@"%@", NSStringFromRange(result.range));
        [self.Links addObject:[result.URL absoluteString]];
        [self.attrText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:200/255.0f green:97/255.0f blue:41/255.0f alpha:1.0f] range:result.range];
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


+(NSArray *)organizeComments:(NSMutableArray *)comments topLevelID:(NSString *)topLevelID {
    NSMutableArray *organizedComments = [@[] mutableCopy];
    NSMutableArray *topLevelComments = [@[] mutableCopy];
    
    // 1. Find all Top-Level comments
    for (Comment *comment in comments) {
        if ([comment.ParentID isEqualToString:topLevelID]) {
            [topLevelComments addObject:comment];
        }
    }
    
    // 2. Add Children to Top-Level
    for (Comment *comment in topLevelComments) {
        [Comment addChildrenToComment:comment fromPool:comments];
    }
    
    // 3. Get Levels and add to a single layer Array
    for (Comment *comment in topLevelComments) {
        [Comment addLevel:0 toComment:comment forArray:organizedComments];
    }
    
    return organizedComments;
}

// Recursively adds Children comments to original Comment
// passed in from the pool of comments.
+(void)addChildrenToComment:(Comment *)comment fromPool:(NSMutableArray *)pool {
    for (Comment *poolComment in pool) {
        if ([poolComment.ParentID isEqualToString:comment.CommentID]) {
            [comment.Children addObject:poolComment];
            [Comment addChildrenToComment:poolComment fromPool:pool];
        }
    }
}

// Recursively changes the linked-list of comments
// into a single-layer array, and keeps the order so nested
// comments look good (Level property)
+(void)addLevel:(int)level toComment:(Comment *)comment forArray:(NSMutableArray *)orderedArray {
    comment.Level = level;
    [orderedArray addObject:comment];
    for (Comment *childComment in comment.Children) {
        [Comment addLevel:level+1 toComment:childComment forArray:orderedArray];
    }
}

@end
