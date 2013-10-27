//
//  HNWebService.h
//  libHN-Demo
//
//  Created by Ben Gordon on 10/6/13.
//  Copyright (c) 2013 subvertapps. All rights reserved.
//

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
    PostFilterTypeBest
};

typedef NS_ENUM(NSInteger, VoteDirection) {
    VoteDirectionUp,
    VoteDirectionDown
};


#pragma mark - Blocks
typedef void (^GetPostsCompletion) (NSArray *posts);
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
- (void)fetchSubmissionsForUser:(NSString *)user completion:(GetPostsCompletion)completion;
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
