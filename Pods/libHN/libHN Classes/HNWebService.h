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
#import "HNComment.h"
#import "HNUser.h"

#pragma mark - Enums
typedef NS_ENUM(NSInteger, PostFilterType) {
    PostFilterTypeTop,
    PostFilterTypeAsk,
    PostFilterTypeNew,
    PostFilterTypeJobs,
    PostFilterTypeBest,
    PostFilterTypeShowHN
};

typedef NS_ENUM(NSInteger, VoteDirection) {
    VoteDirectionUp,
    VoteDirectionDown
};


#pragma mark - Blocks
typedef void (^GetPostsCompletion) (NSArray *posts, NSString *nextPageIdentifier);
typedef void (^GetCommentsCompletion) (NSArray *comments);
typedef void (^LoginCompletion) (HNUser *user, NSHTTPCookie *cookie);
typedef void (^BooleanSuccessBlock) (BOOL success);
typedef void (^SubmitPostSuccessBlock) (BOOL success);
typedef void (^SubmitCommentSuccessBlock) (BOOL success);


#pragma mark - HNWebService
@interface HNWebService : NSObject

// Properties
@property (nonatomic, retain) NSOperationQueue *HNQueue;

// Methods
// Get Posts
- (void)loadPostsWithFilter:(PostFilterType)filter completion:(GetPostsCompletion)completion;
- (void)loadPostsWithUrlAddition:(NSString *)urlAddition completion:(GetPostsCompletion)completion;
// Get Comments
- (void)loadCommentsFromPost:(HNPost *)post completion:(GetCommentsCompletion)completion;
// Login/Out
- (void)loginWithUsername:(NSString *)user pass:(NSString *)pass completion:(LoginCompletion)completion;
- (void)validateAndSetSessionWithCookie:(NSHTTPCookie *)cookie completion:(LoginCompletion)completion;
// Submitting
- (void)submitPostWithTitle:(NSString *)title link:(NSString *)link text:(NSString *)text completion:(BooleanSuccessBlock)completion;
// Commenting
- (void)replyToHNObject:(id)hnObject withText:(NSString *)text completion:(BooleanSuccessBlock)completion;
// Voting
- (void)voteOnHNObject:(id)hnObject direction:(VoteDirection)direction completion:(BooleanSuccessBlock)completion;
// Get Submissions for User
- (void)fetchSubmissionsForUser:(NSString *)user urlAddition:(NSString *)urlAddition completion:(GetPostsCompletion)completion;
// Cancel Requests
- (void)cancelAllRequests;

@end


#pragma mark - HNOperation
@interface HNOperation : NSOperation

// Properties
@property (nonatomic, retain) NSURLRequest *urlRequest;
@property (nonatomic, retain) NSData *bodyData;
@property (nonatomic, retain) NSData *responseData;
@property (nonatomic, retain) NSHTTPURLResponse *response;

// Set Path
-(void)setUrlPath:(NSString *)path data:(NSData *)data cookie:(NSHTTPCookie *)cookie completion:(void (^)(void))block;

// Web Request Builders
+(NSMutableURLRequest *)newGetRequestForURL:(NSURL *)url cookie:(NSHTTPCookie *)cookie;
+(NSMutableURLRequest *)newJSONRequestWithURL:(NSURL *)url bodyData:(NSData *)bodyData cookie:(NSHTTPCookie *)cookie;

@end
