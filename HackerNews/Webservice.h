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

@protocol WebserviceDelegate
@optional

-(void)didFetchPosts:(NSArray *)posts;
-(void)didFetchComments:(NSArray *)comments forPostID:(NSString *)postID launchComments:(BOOL)launch;
-(void)didLoginWithUser:(User *)user;

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

@end
