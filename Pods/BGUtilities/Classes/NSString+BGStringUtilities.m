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

#import "NSString+BGStringUtilities.h"

@implementation NSString (BGStringUtilities)

#pragma mark - Contains
- (BOOL)contains:(NSString *)searchString {
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", searchString];
    return [searchPredicate evaluateWithObject:self];
}

- (BOOL)containsAnyInArray:(NSArray *)searchArray {
    // return NO if no objects
    if (searchArray.count == 0) { return NO; }
    
    // Check against objects until a match is found
    __block BOOL returnBOOL = NO;
    [searchArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            if ([self contains:(NSString *)obj]) {
                returnBOOL = YES;
                *stop = YES;
            }
        }
    }];
    
    return returnBOOL;
}


#pragma mark - REGEX
- (BOOL)matchesRegex:(NSString *)regexString {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
    return match ? YES : NO;
}

- (void)enumerateRegexMatches:(NSString *)regexString usingBlock:(void (^)(NSString *match, NSInteger index, NSRange matchRange, BOOL *stop))block {
    // Find matches with regular expression
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    
    // Enumerate them
    if (matches.count > 0) {
        [matches enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSTextCheckingResult *result = (NSTextCheckingResult *)obj;
            block([self substringWithRange:result.range], idx, result.range, stop);
        }];
    }
}


#pragma mark - Email Validation
- (BOOL)isValidEmail {
    return [self matchesRegex:@"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$"];
}


#pragma mark - Words
- (NSArray *)words {
    __block NSMutableArray *words = [NSMutableArray array];
    [self enumerateWordsUsingBlock:^(NSString *word, NSInteger index, BOOL *stop) {
        [words addObject:word];
    }];
    
    // Return words
    return words;
}

- (NSSet *)uniqueWords {
    return [NSSet setWithArray:[self words]];
}

- (NSInteger)numberOfWords {
    __block int count = 0;
    [self enumerateWordsUsingBlock:^(NSString *word, NSInteger index, BOOL *stop) {
        count++;
    }];
    
    return count;
}

- (void)enumerateWordsUsingBlock:(void (^)(NSString *word, NSInteger index, BOOL *stop))block {
    // Create Linguistic Tagger
    NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation;
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:[NSLinguisticTagger availableTagSchemesForLanguage:@"en"] options:options];
    tagger.string = self;
    
    // Set Up Enumeration
    __block NSInteger index = 0;
    
    // Enumerate the tags and add to words
    [tagger enumerateTagsInRange:NSMakeRange(0, [self length]) scheme:NSLinguisticTagSchemeNameTypeOrLexicalClass options:options usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
        block([self substringWithRange:tokenRange], index, stop);
        index++;
    }];
}


#pragma mark - Concatenate
+ (instancetype)stringByConcatenating:(NSString *)aString, ... NS_REQUIRES_NIL_TERMINATION {
    // Set Up
    NSMutableString *newString = [NSMutableString string];
    va_list args;
    
    // Traverse the strings
    va_start(args, aString);
    for (NSString *arg = aString; arg != nil; arg = va_arg(args, NSString*)) {
        [newString appendString:arg];
    }
    va_end(args);
    
    return [newString copy];
}


@end
