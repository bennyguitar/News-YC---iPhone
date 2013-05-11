//
//  HNSingleton.h
//  HackerNews
//
//  Created by Ben Gordon on 1/19/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "IIViewDeckController.h"
#import "SubmitLinkViewController.h"
#import "Webservice.h"
#import "KGStatusBar.h"
#import "User.h"
#import "Post.h"
#import "Comment.h"

enum fType {
    fTypeTop = 0,
    fTypeNew = 1,
    fTypeAsk = 2
};

enum sDirection {
    scrollDirectionUp = 0,
    scrollDirectionDown = 1,
};

enum theme {
    themeNight = 0,
    themeDay = 1
};

@interface HNSingleton : NSObject <WebserviceDelegate> {
}

@property (nonatomic, retain) NSMutableDictionary *hasReadThisArticleDict;
@property (nonatomic, retain) NSMutableDictionary *votedForDictionary;
@property (nonatomic, retain) NSMutableDictionary *themeDict;
@property (nonatomic, assign) enum fType filter;
@property (nonatomic, retain) NSHTTPCookie *SessionCookie;
@property (nonatomic, retain) User *User;


+(HNSingleton*)sharedHNSingleton;
-(void)changeTheme;
-(void)setSession;
-(void)loginWithUser:(NSString *)user password:(NSString *)pass;
-(void)logout;
-(void)addToVotedForDictionary:(id)HNObject votedUp:(BOOL)up;
-(BOOL)objectIsInVoteDict:(id)HNObject;

@end
