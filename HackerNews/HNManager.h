//
//  HNManager.h
//  libHN-Demo
//
//  Created by Ben Gordon on 10/6/13.
//  Copyright (c) 2013 subvertapps. All rights reserved.
//

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
