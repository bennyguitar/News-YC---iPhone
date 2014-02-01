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
/**
 This is the singleton object that all of your HN API calls will go through. It also keeps track of what a user has voted on, and which posts a user has read.
 */
+ (HNManager *)sharedManager;

#pragma mark - Session
/**
 This is the ideal method to start the HNManager session. It attempts to find a cookie and log a user in if it does find one. You should call this method in the AppDelegate.
 */
- (void)startSession;

/**
 Determines if a user is currently logged in or not.
 @return    BOOL for YES a user is logged in.
 */
- (BOOL)userIsLoggedIn;

#pragma mark - WebService Methods
/**
 Attempts to login to HackerNews with a username and password.
 @param user   - HackerNews username
 @param pass   - HackerNews password
 @return    HNUser in the completion block if successful
 */
- (void)loginWithUsername:(NSString *)user password:(NSString *)pass completion:(SuccessfulLoginBlock)completion;

/**
 Ends the current HN session, and destroys the cookie
 */
- (void)logout;

/**
 Loads posts from HN. The filter parameter filters your returned posts to Top, New, Ask, Jobs, or Best.
 @param filter   - PostFilterType for what you want
 @return    NSArray of HNPost objects
 */
- (void)loadPostsWithFilter:(PostFilterType)filter completion:(GetPostsCompletion)completion;

/**
 Loads posts from HN using a url addition. HN uses an fnid or /news2 to grab the next batch of posts. Use this method to grab posts 31 - n of whatever filter type you are on. The most common urlAddition is stored in the [[HNManager sharedManager] postUrlAddition] object.
 @param urlAddition   - NSString of the url addition.
 @return    NSArray of HNPost objects
 */
- (void)loadPostsWithUrlAddition:(NSString *)urlAddition completion:(GetPostsCompletion)completion;

/**
 Loads comments for a given HNPost object.
 @param post   - HNPost object.
 @return    NSArray of HNComment objects
 */
- (void)loadCommentsFromPost:(HNPost *)post completion:(GetCommentsCompletion)completion;

/**
 Attempts to submit a new HNPost object to HackerNews. You must have a title, and you must have either a link or text. If you don't, the completion block will return NO. If the completion block returns YES, then your submission was successful and is live on HN.
 @param title   - The title of the new post (required)
 @param link    - Link of the new post (optional)
 @param text    - Text post to HN, instead of a link (optional)
 @return    BOOL for success
 */
- (void)submitPostWithTitle:(NSString *)title link:(NSString *)link text:(NSString *)text completion:(BooleanSuccessBlock)completion;

/**
 Attempts to submit a new HNComment object to HackerNews. This can be a comment on an HNPost or another HNComment object. hnObject and text must not be nil.
 @param hnObject   - HNPost or HNComment (required)
 @param text       - Comment text (required)
 @return    BOOL for success
 */
- (void)replyToPostOrComment:(id)hnObject withText:(NSString *)text completion:(BooleanSuccessBlock)completion;

/**
 Attempts to vote on an HNPost or HNComment object. You can only vote UP on HNPost objects. A user can only vote DOWN on HNComment objects if they have >= 500 karma points.
 @param hnObject   - HNPost or HNComment (required)
 @param direction  - VoteDirection enum (required)
 @return    BOOL for success
 */
- (void)voteOnPostOrComment:(id)hnObject direction:(VoteDirection)direction completion:(BooleanSuccessBlock)completion;

/**
 Loads posts from HN for a given username. To get the next batch of posts for a user, use the [[HNManager sharedManager] userSubmissionUrlAddition] object and the - (void)loadPostsWithUrlAddition:(NSString *)urlAddition completion:(GetPostsCompletion)completion method.
 @param user   - NSString of the username
 @return    NSArray of HNPost objects
 */
- (void)fetchSubmissionsForUser:(NSString *)user completion:(GetPostsCompletion)completion;

#pragma mark - Internal Methods
+ (NSHTTPCookie *)getHNCookie;

#pragma mark - Mark as Read
/**
 Determines if a user has read an HNPost object.
 @param post   - HNPost object
 @return    BOOL for YES they have read or NO they have not.
 */
- (BOOL)hasUserReadPost:(HNPost *)post;

/**
 Adds an HNPost to the Manager for knowing if a user has read it or not. This is syncronized with the NSUserDefaults to keep track any time the app is used.
 @param post   - HNPost object
 */
- (void)setMarkAsReadForPost:(HNPost *)post;

#pragma mark - Voted On
/**
 Determines if a user has voted on an HNPost or HNComment object.
 @param hnObject   - HNPost or HNComment object
 @return    BOOL for YES they have voted or NO they have not.
 */
- (BOOL)hasVotedOnObject:(id)hnObject;

/**
 Adds an HNPost or HNComment to the Manager for knowing if a user has voted on  it or not. This is syncronized with the NSUserDefaults to keep track any time the app is used.
 @param hnObject   - HNPost or HNComment object
 */
- (void)addHNObjectToVotedOnDictionary:(id)hnObject direction:(VoteDirection)direction;

#pragma mark - Cancel All WebRequests
- (void)cancelAllRequests;

@end
