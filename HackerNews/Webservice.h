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

@protocol WebserviceDelegate
@optional

-(void)webservice:(Webservice *)webservice didFetchPosts:(NSArray *)posts;
-(void)webservice:(Webservice *)webservice didFetchComments:(NSArray *)comments forPostID:(NSString *)postID launchComments:(BOOL)launch;
-(void)webservice:(Webservice *)webservice didLoginWithUser:(User *)user;
-(void)webservice:(Webservice *)webservice didVoteWithSuccess:(BOOL)success forObject:(id)object direction:(BOOL)up;

@end

@interface Webservice : NSObject {
    __weak id <WebserviceDelegate> delegate;
}
//Delegate
@property (weak) id <WebserviceDelegate> delegate;

// Methods
-(void)getHomepage;
-(void)getCommentsForPost:(Post *)post launchComments:(BOOL)launch;
-(void)loginWithUsername:(NSString *)user password:(NSString *)pass;
-(void)voteUp:(BOOL)up forObject:(id)HNObject;

@end
