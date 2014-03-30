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

typedef NS_ENUM(NSInteger, PostType) {
    PostTypeDefault,
    PostTypeAskHN,
    PostTypeJobs
};

@interface HNPost : NSObject

#pragma mark - Properties
@property (nonatomic, assign) PostType Type;
@property (nonatomic,retain) NSString *Username;
@property (nonatomic, retain) NSString *UrlString;
@property (nonatomic, retain, readonly) NSString *UrlDomain;
@property (nonatomic, retain) NSString *Title;
@property (nonatomic, assign) int Points;
@property (nonatomic, assign) int CommentCount;
@property (nonatomic, retain) NSString *PostId;
@property (nonatomic, retain) NSString *TimeCreatedString;
@property (nonatomic, retain) NSString *UpvoteURLAddition;

#pragma mark - Methods
+ (NSArray *)parsedPostsFromHTML:(NSString *)html FNID:(NSString **)fnid;

@end
