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
#import "HNPost.h"

typedef NS_ENUM(NSInteger, HNCommentType) {
    HNCommentTypeDefault,
    HNCommentTypeAskHN,
    HNCommentTypeJobs
};

@interface HNComment : NSObject

#pragma mark - Properties
@property (nonatomic, assign) HNCommentType Type;
@property (nonatomic, retain) NSString *Text;
@property (nonatomic, retain) NSString *Username;
@property (nonatomic, retain) NSString *CommentId;
@property (nonatomic, retain) NSString *ParentID;
@property (nonatomic, retain) NSString *TimeCreatedString;
@property (nonatomic, retain) NSString *ReplyURLString;
@property (nonatomic, assign) int Level;
@property (nonatomic, retain) NSArray *Links;
@property (nonatomic, retain) NSString *UpvoteURLAddition;
@property (nonatomic, retain) NSString *DownvoteURLAddition;

#pragma mark - Methods
+ (NSArray *)parsedCommentsFromHTML:(NSString *)html forPost:(HNPost *)post;


@end
