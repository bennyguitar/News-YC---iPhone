//
//  HNManager.m
//  libHN-Demo
//
//  Created by Ben Gordon on 10/6/13.
//  Copyright (c) 2013 subvertapps. All rights reserved.
//

#import "HNManager.h"

@implementation HNManager

// Build the static manager object
static HNManager * _sharedManager = nil;


#pragma mark - Set Up HNManager's Singleton
+ (HNManager *)sharedManager {
	@synchronized([HNManager class]) {
		if (!_sharedManager)
            _sharedManager  = [[HNManager alloc] init];
		return _sharedManager;
	}
	return nil;
}

+ (id)alloc {
	@synchronized([HNManager class]) {
		NSAssert(_sharedManager == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedManager = [super alloc];
		return _sharedManager;
	}
	return nil;
}

- (instancetype)init {
	if (self = [super init]) {
        // Set up Webservice
        self.Service = [[HNWebService alloc] init];
        
        // Set up Voted On Dictionary
        self.VotedOnDictionary = [NSMutableDictionary dictionary];
        
        // Set Mark As Read
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"HN-MarkAsRead"]) {
            self.MarkAsReadDictionary = [[[NSUserDefaults standardUserDefaults] objectForKey:@"HN-MarkAsRead"] mutableCopy];
        }
        else {
            self.MarkAsReadDictionary = [NSMutableDictionary dictionary];
        }
	}
	return self;
}

#pragma mark - Start Session
- (void)startSession {
    // Set Values from Defaults
    self.SessionCookie = [HNManager getHNCookie];
    
    // Validate User/Cookie
    [self validateAndSetCookieWithCompletion:^(HNUser *user, NSHTTPCookie *cookie) {
        if (user) {
            self.SessionUser = user;
        }
        else {
            self.SessionUser = nil;
        }
        if (cookie) {
            self.SessionCookie = cookie;
        }
        else {
            self.SessionCookie = nil;
        }
        
        // Post Notification
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidLoginOrOut" object:nil];
    }];
}


#pragma mark - Set Session Cookie & Username
- (void)setCookie:(NSHTTPCookie *)cookie user:(HNUser *)user {
    // Set Session
    self.SessionUser = user;
    self.SessionCookie = cookie;
}

#pragma mark - Check for Logged In User
- (BOOL)userIsLoggedIn {
    return self.SessionCookie && self.SessionUser;
}


#pragma mark - WebService Methods
- (void)loginWithUsername:(NSString *)user password:(NSString *)pass completion:(SuccessfulLoginBlock)completion {
    [self.Service loginWithUsername:user pass:pass completion:^(HNUser *user, NSHTTPCookie *cookie) {
        if (user && cookie) {
            // Set Cookie & User
            [self setCookie:cookie user:user];
            
            // Post Notification
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DidLoginOrOut" object:nil];

            // Pass user on through
            completion(user);
        }
        else {
            completion(nil);
        }
    }];
}

- (void)logout {
    // Delete cookie from Storage
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:self.SessionCookie];
    
    // Delete objects in memory
    self.SessionCookie = nil;
    self.SessionUser = nil;
    
    // Post Notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidLoginOrOut" object:nil];
}

- (void)loadPostsWithFilter:(PostFilterType)filter completion:(GetPostsCompletion)completion {
    // Reset PostUrlAddition
    self.postUrlAddition = nil;
    
    // Load post
    [self.Service loadPostsWithFilter:filter completion:completion];
}

- (void)loadPostsWithUrlAddition:(NSString *)urlAddition completion:(GetPostsCompletion)completion {
    [self.Service loadPostsWithUrlAddition:urlAddition completion:completion];
}

- (void)loadCommentsFromPost:(HNPost *)post completion:(GetCommentsCompletion)completion {
    [self.Service loadCommentsFromPost:post completion:completion];
}

- (void)submitPostWithTitle:(NSString *)title link:(NSString *)link text:(NSString *)text completion:(BooleanSuccessBlock)completion {
    if ((!link && !text) || !title) {
        // No link and text, or no title - can't submit
        completion(NO);
        return;
    }
    
    // Make the Webservice Call
    [self.Service submitPostWithTitle:title link:link text:text completion:completion];
}

- (void)replyToPostOrComment:(id)hnObject withText:(NSString *)text completion:(BooleanSuccessBlock)completion {
    if (!hnObject || !text) {
        // You need a Post/Comment and text to make a reply!
        completion(NO);
        return;
    }
    
    // Make the Webservice call
    [self.Service replyToHNObject:hnObject withText:text completion:completion];
}

- (void)voteOnPostOrComment:(id)hnObject direction:(VoteDirection)direction completion:(BooleanSuccessBlock)completion {
    if (!(hnObject || direction)) {
        // Must be a Post/Comment and direction to vote!
        completion(NO);
        return;
    }
    
    // Make the Webservice Call
    [self.Service voteOnHNObject:hnObject direction:direction completion:completion];
}

- (void)fetchSubmissionsForUser:(NSString *)user completion:(GetPostsCompletion)completion {
    if (!user) {
        // Need a username to get their submissions!
        completion(nil);
        return;
    }
    
    // Make the webservice call
    [self.Service fetchSubmissionsForUser:user completion:completion];
}


#pragma mark - Set Cookie & User
- (void)validateAndSetCookieWithCompletion:(LoginCompletion)completion {
    NSHTTPCookie *cookie = [HNManager getHNCookie];
    if (cookie) {
        [self.Service validateAndSetSessionWithCookie:cookie completion:completion];
    }
}

+ (NSHTTPCookie *)getHNCookie {
    NSArray *cookieArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"https://news.ycombinator.com/"]];
    if (cookieArray.count > 0) {
        NSHTTPCookie *cookie = cookieArray[0];
        if ([cookie.name isEqualToString:@"user"]) {
            return cookie;
        }
    }
    
    return nil;
}

- (BOOL)isUserLoggedIn {
    return (self.SessionCookie != nil && self.SessionUser != nil);
}


#pragma mark - Mark As Read
- (BOOL)hasUserReadPost:(HNPost *)post {
    return self.MarkAsReadDictionary[post.PostId] ? YES : NO;
}

- (void)setMarkAsReadForPost:(HNPost *)post {
    [self.MarkAsReadDictionary setObject:@YES forKey:post.PostId];
    [[NSUserDefaults standardUserDefaults] setObject:self.MarkAsReadDictionary forKey:@"HN-MarkAsRead"];
}

#pragma mark - Voted On Dictionary
- (BOOL)hasVotedOnObject:(id)hnObject {
    NSString *votedOnId = [hnObject isKindOfClass:[HNPost class]] ? [(HNPost *)hnObject PostId] : [(HNComment *)hnObject CommentId];
    return [self.VotedOnDictionary objectForKey:votedOnId] != nil ? YES : NO;
}

- (void)addHNObjectToVotedOnDictionary:(id)hnObject direction:(VoteDirection)direction {
    NSString *votedOnId = [hnObject isKindOfClass:[HNPost class]] ? [(HNPost *)hnObject PostId] : [(HNComment *)hnObject CommentId];
    [self.VotedOnDictionary setObject:@(direction) forKey:votedOnId];
}

#pragma mark - Cancel Requests
- (void)cancelAllRequests {
    [self.Service cancelAllRequests];
}

@end
