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

#import <Foundation/Foundation.h>

@interface NSString (BGStringUtilities)


#pragma mark - Contains
/**
 A shorthand method that uses NSPredicate to determine if an NSString contains another NSString. This uses a case-insensitive comparison.
 @param searchString    - NSString to check against self
 @returns BOOL
 */
- (BOOL)contains:(NSString *)searchString;

/**
 A shorthand method that uses NSPredicate to determine if an NSString contains any NSString objects inside of an array. This uses a case-insensitive comparison.
 @param searchArray    - NSArray of NSStrings
 @returns BOOL
 */
- (BOOL)containsAnyInArray:(NSArray *)searchArray;


#pragma mark - REGEX
/**
 Takes in a regular expression string to determine whether self evaluates with it or not.
 @param regexString - NSString of the regular expression
 @returns BOOL
 */
- (BOOL)matchesRegex:(NSString *)regexString;

/**
 Takes in a regular expression string and enumerates all of the matches found. Set stop = YES to end the enumeration loop.
 @param regexString - NSString of the regular expression
 */
- (void)enumerateRegexMatches:(NSString *)regexString usingBlock:(void (^)(NSString *match, NSInteger index, NSRange matchRange, BOOL *stop))block;


#pragma mark - Email Validation
/**
 Uses regex to determine whether the string is a valid email address or not.
 @returns BOOL
 */
- (BOOL)isValidEmail;


#pragma mark - Words
/**
 Returns an NSArray of words from the string.
 @returns NSArray
 */
- (NSArray *)words;

/**
 Returns an NSSet of the number of unique words in the string. Does not take into account plural vs. singular in determining if a word is there or not. Cats and cat are unique words.
 @returns NSSet
 */
- (NSSet *)uniqueWords;

/**
 Returns an NSInteger representing how many words the string contains. This method counts all words, and not unique ones.
 @returns NSArray
 */
- (NSInteger)numberOfWords;

/**
 Uses a block to enumerate through all of the words in the string. Set stop to YES whenever you want to finish enumerating.
 */
- (void)enumerateWordsUsingBlock:(void (^)(NSString *word, NSInteger index, BOOL *stop))block;


#pragma mark - Concatenate
/**
 Returns an NSString after concatenating all of the strings in the order they are in the passed in.
 @param @"Hello",@"World"
 @return NSString
 */
+ (instancetype)stringByConcatenating:(NSString *)string, ... NS_REQUIRES_NIL_TERMINATION;

@end
