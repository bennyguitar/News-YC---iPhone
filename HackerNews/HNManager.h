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

#import "HNWebService.h"

@interface HNManager : NSObject

#pragma mark - Blocks
typedef void (^SuccessfulLoginBlock) (HNUser *user);

#pragma mark - Properties
@property (nonatomic, retain) HNWebService *Service;
@property (nonatomic, retain) NSString *postUrlAddition;
@property (nonatomic, retain) NSString *userSubmissionUrlAddition;
@property (nonatomic, retain) NSHTTPCookie *SessionCookie;
@property (nonatomic, retain) HNUser *SessionUser;
@property (nonatomic, retain) NSMutableDictionary *MarkAsReadDictionary;
@property (nonatomic, retain) NSMutableDictionary *VotedOnDictionary;

#pragma mark - Singleton Manager
+ (HNManager *)sharedManager;

#pragma mark - Session
- (void)startSession;
- (BOOL)userIsLoggedIn;

#pragma mark - WebService Methods
- (void)loginWithUsername:(NSString *)user password:(NSString *)pass completion:(SuccessfulLoginBlock)completion;
- (void)logout;
- (void)loadPostsWithFilter:(PostFilterType)filter completion:(GetPostsCompletion)completion;
- (void)loadPostsWithUrlAddition:(NSString *)urlAddition completion:(GetPostsCompletion)completion;
- (void)loadCommentsFromPost:(HNPost *)post completion:(GetCommentsCompletion)completion;
- (void)submitPostWithTitle:(NSString *)title link:(NSString *)link text:(NSString *)text completion:(BooleanSuccessBlock)completion;
- (void)replyToPostOrComment:(id)hnObject withText:(NSString *)text completion:(BooleanSuccessBlock)completion;
- (void)voteOnPostOrComment:(id)hnObject direction:(VoteDirection)direction completion:(BooleanSuccessBlock)completion;
- (void)fetchSubmissionsForUser:(NSString *)user completion:(GetPostsCompletion)completion;

#pragma mark - Internal Methods
+ (NSHTTPCookie *)getHNCookie;

#pragma mark - Mark as Read
- (BOOL)hasUserReadPost:(HNPost *)post;
- (void)setMarkAsReadForPost:(HNPost *)post;

#pragma mark - Voted On
- (BOOL)hasVotedOnObject:(id)hnObject;
- (void)addHNObjectToVotedOnDictionary:(id)hnObject direction:(VoteDirection)direction;

#pragma mark - Cancel All WebRequests
- (void)cancelAllRequests;

@end
