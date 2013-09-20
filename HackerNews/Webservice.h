//
//  Webservice.h
//  HackerNews
//
//  Created by Benjamin Gordon with help by @MatthewYork on 4/28/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"
#import "Comment.h"
#import "User.h"

@class Webservice;

#pragma mark - Delegate
@protocol WebserviceDelegate
@optional

-(void)webservice:(Webservice *)webservice didFetchPosts:(NSArray *)posts;
-(void)webservice:(Webservice *)webservice didLoginWithUser:(User *)user;
-(void)webservice:(Webservice *)webservice didVoteWithSuccess:(BOOL)success forObject:(id)object direction:(BOOL)up;

@end

#pragma mark - Blocks
// HomePage
typedef void (^GetHomeSuccessBlock)(NSArray *posts);
typedef void (^GetHomeFailureBlock)();
// Comments
typedef void (^GetCommentsSuccessBlock)(NSArray *comments);
typedef void (^GetCommentsFailureBlock)();
// Submit Post Block
typedef void (^SubmitLinkSuccessBlock)();
typedef void (^SubmitLinkFailureBlock)();


#pragma mark - WebService Class
@interface Webservice : NSObject {
    __weak id <WebserviceDelegate> delegate;
}

// Delegate
@property (weak) id <WebserviceDelegate> delegate;

// OperationQueue
@property (nonatomic, retain) NSOperationQueue *HNOperationQueue;

// IsLoadingFnid
@property (nonatomic, assign) BOOL isLoadingFromFNID;

// Methods
-(void)getHomepageWithSuccess:(GetHomeSuccessBlock)success failure:(GetHomeFailureBlock)failure;
-(void)getHomepageFromFnid:(NSString *)fnid withSuccess:(GetHomeSuccessBlock)success failure:(GetHomeFailureBlock)failure;
-(void)getCommentsForPost:(Post *)post success:(GetCommentsSuccessBlock)success failure:(GetCommentsFailureBlock)failure;
-(void)loginWithUsername:(NSString *)user password:(NSString *)pass;
-(void)voteUp:(BOOL)up forObject:(id)HNObject;
-(void)submitLink:(NSString *)urlPath orText:(NSString *)textPost title:(NSString *)title success:(SubmitLinkSuccessBlock)success failure:(SubmitLinkFailureBlock)failure;
- (void)lockFNIDLoading;
- (void)unlockFNIDLoading;

@end
