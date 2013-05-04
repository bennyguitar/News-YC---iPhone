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
        self.Level = 0;
        self.TimeCreated = [NSDate date];
        self.CellType = CommentTypeOpen;
    }
    return self;
}

+(Comment *)commentFromDictionary:(NSDictionary *)dict {
    Comment *newComment = [[Comment alloc] init];
    
    if ([dict objectForKey:@"text"] != [NSNull null]) {
        [newComment setUpComment:[dict objectForKey:@"text"]];
    }
    
    newComment.CommentID = [dict objectForKey:@"_id"];
    newComment.ParentID = [dict objectForKey:@"parent_sigid"];
    newComment.Username = [dict objectForKey:@"username"];
    newComment.Level = 0;
    newComment.TimeCreated = [Helpers postDateFromString:[dict objectForKey:@"create_ts"]];
    
    return newComment;
}

-(void)setUpComment:(NSString *)text {
    text = [text stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n\n"];
    text = [text stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"<i>" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"</i>" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"&#38;" withString:@"&"];
    text = [text stringByReplacingOccurrencesOfString:@"&#62;" withString:@">"];
    text = [text stringByReplacingOccurrencesOfString:@"&#60;" withString:@"<"];
    text = [text stringByReplacingOccurrencesOfString:@"<pre><code>" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"</code></pre>" withString:@""];
    
    
    NSArray *linkTextComponents = [text componentsSeparatedByString:@"<a href=\""];
    NSString *newString = @"";
    for (int xx = 0; xx < linkTextComponents.count; xx++) {
        NSString *component = linkTextComponents[xx];
        if (xx == 0) {
            newString = component;
        }
        else {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ contains[c] SELF", component];
            if ([predicate evaluateWithObject:@"</a>"]) {
                // Contains a link
                NSScanner *scanner = [NSScanner scannerWithString:component];
                NSString *linkString=@"";
                [scanner scanUpToString:@"\" rel=" intoString:&linkString];
                [self.Links addObject:linkString];
                newString = [newString stringByAppendingString:[NSString stringWithFormat:@" %@", linkString]];
                
                // Now grab the rest of the comment after the link
                // and add it back to newString
                NSArray *commentComponents = [component componentsSeparatedByString:@"</a>"];
                if (commentComponents.count > 1) {
                    newString = [newString stringByAppendingString:[NSString stringWithFormat:@" %@",commentComponents[1]]];
                }
            }
            else {
                // No Link
                newString = [newString stringByAppendingString:[NSString stringWithFormat:@" %@", component]];
            }
        }
    }
    
    self.Text = linkTextComponents.count > 0 ? newString : text;
}

-(void)setUpCommentText {
    self.Text = [self.Text stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n\n"];
    self.Text = [self.Text stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    self.Text = [self.Text stringByReplacingOccurrencesOfString:@"</i>" withString:@""];
    self.Text = [self.Text stringByReplacingOccurrencesOfString:@"&#38;" withString:@"&"];
    self.Text = [self.Text stringByReplacingOccurrencesOfString:@"&#62;" withString:@">"];
    self.Text = [self.Text stringByReplacingOccurrencesOfString:@"&#60;" withString:@"<"];
    
    NSArray *linkTextComponents = [self.Text componentsSeparatedByString:@"<a href=\""];
    NSString *newString = @"";
    for (int xx = 0; xx < linkTextComponents.count; xx++) {
        NSString *component = linkTextComponents[xx];
        if (xx == 0) {
            newString = component;
        }
        else {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ contains[c] SELF", component];
            if ([predicate evaluateWithObject:@"</a>"]) {
                // Contains a link
                NSScanner *scanner = [NSScanner scannerWithString:component];
                NSString *linkString=@"";
                [scanner scanUpToString:@"\" rel=" intoString:&linkString];
                [self.Links addObject:linkString];
                newString = [newString stringByAppendingString:[NSString stringWithFormat:@" %@", linkString]];
                
                // Now grab the rest of the comment after the link
                // and add it back to newString
                NSArray *commentComponents = [component componentsSeparatedByString:@"</a>"];
                if (commentComponents.count > 1) {
                    newString = [newString stringByAppendingString:[NSString stringWithFormat:@" %@",commentComponents[1]]];
                }
            }
            else {
                // No Link
                newString = [newString stringByAppendingString:[NSString stringWithFormat:@" %@", component]];
            }
        }
    }
    
    self.Text = linkTextComponents.count > 0 ? newString : self.Text;
    
    self.attrText = [[NSMutableAttributedString alloc] initWithString:self.Text];
    
    // Paragraph Style
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    // Find italic substring
    NSRange iRange = NSMakeRange(0, self.attrText.length);
    while(iRange.location != NSNotFound)
    {
        iRange = [self.attrText.string rangeOfString:@"<i>" options:0 range:iRange];
        if(iRange.location != NSNotFound) {
            iRange = NSMakeRange(iRange.location + iRange.length, self.attrText.length - (iRange.location + iRange.length));
        }
    }
    
    // Add attributes
    [self.attrText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveitcaNeue" size:14] range:NSMakeRange(0, self.attrText.length)];
    [self.attrText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.attrText.length)];
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
