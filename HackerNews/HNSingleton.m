//
//  HNSingleton.m
//  HackerNews
//
//  Created by Ben Gordon on 1/19/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "HNSingleton.h"

@implementation HNSingleton

static HNSingleton * _sharedHNSingleton = nil;

+(HNSingleton*)sharedHNSingleton;
{
	@synchronized([HNSingleton class])
	{
		if (!_sharedHNSingleton)
            _sharedHNSingleton  = [[HNSingleton alloc]init];
		
		return _sharedHNSingleton;
	}
	
	return nil;
}



+(id)alloc
{
	@synchronized([HNSingleton class])
	{
		NSAssert(_sharedHNSingleton == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedHNSingleton = [super alloc];
		return _sharedHNSingleton;
	}
	
	return nil;
}




-(id)init {
	self = [super init];
	if (self != nil) {
		self.hasReadThisArticleDict = [@{} mutableCopy];
        self.themeDict = [@{} mutableCopy];
        self.filter = fTypeTop;
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"VotedFor"]) {
            self.votedForDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"VotedFor"];
        }
        else {
            self.votedForDictionary = [@{} mutableCopy];
        }
	}
	
	return self;
}


-(void)changeTheme {
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"Theme"] isEqualToString:@"Night"]) {
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.2 alpha:1.0] forKey:@"CellBG"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.92 alpha:1.0] forKey:@"MainFont"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.98 alpha:1.0] forKey:@"SubFont"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.25 alpha:1.0] forKey:@"BottomBar"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.33 alpha:1.0] forKey:@"Separator"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.17 alpha:1.0] forKey:@"TableTriangle"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIImage imageNamed:@"commentbubble-01.png"] forKey:@"CommentBubble"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithRed:53/255.0 green:77/255.0 blue:93/255.0 alpha:1.0] forKey:@"ShowHN"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithRed:47/255.0 green:93/255.0 blue:54/255.0 alpha:1.0] forKey:@"HNJobs"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithRed:44/255.0 green:44/255.0 blue:44/255.0 alpha:1.0] forKey:@"PostActions"];
    }
    else {
        NSLog(@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"Theme"]);
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.85 alpha:1.0] forKey:@"CellBG"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.4 alpha:1.0] forKey:@"MainFont"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.20 alpha:1.0] forKey:@"SubFont"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.75 alpha:1.0] forKey:@"BottomBar"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.70 alpha:1.0] forKey:@"Separator"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithWhite:0.89 alpha:1.0] forKey:@"TableTriangle"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIImage imageNamed:@"commentbubbleDark.png"] forKey:@"CommentBubble"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithRed:183/255.0 green:211/255.0 blue:235/255.0 alpha:1.0] forKey:@"ShowHN"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithRed:170/255.0 green:235/255.0 blue:185/255.0 alpha:1.0] forKey:@"HNJobs"];
        [[HNSingleton sharedHNSingleton].themeDict setValue:[UIColor colorWithRed:144/255.0 green:144/255.0 blue:144/255.0 alpha:1.0] forKey:@"PostActions"];
    }
}

-(void)setSession {
    NSArray *cookieArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"https://news.ycombinator.com/"]];
    if (cookieArray.count > 0) {
        NSHTTPCookie *cookie = cookieArray[0];
        if ([cookie.name isEqualToString:@"user"]) {
            [HNSingleton sharedHNSingleton].SessionCookie = cookie;
        }
    }
}


#pragma mark - Logging In / Out

-(void)loginWithUser:(NSString *)user password:(NSString *)pass {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoggingIn" object:nil];
    Webservice *service = [[Webservice alloc] init];
    service.delegate = self;
    [service loginWithUsername:user password:pass];
}

-(void)webservice:(Webservice *)webservice didLoginWithUser:(User *)user {
    if (user) {
        user.Username = [[NSUserDefaults standardUserDefaults] valueForKey:@"Username"];
        self.User = user;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidLoginOrOut" object:nil];
        [KGStatusBar showSuccessWithStatus:[NSString stringWithFormat:@"%@ Logged In", user.Username]];
    }
    else {
        // Launch failed loading with bad user error
        [KGStatusBar showErrorWithStatus:@"Login Failed"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidLoginOrOut" object:nil];
    }
}

-(void)logout {
    self.User = nil;
    self.SessionCookie = nil;
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"Password"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidLoginOrOut" object:nil];
    [KGStatusBar showWithStatus:@"Logged Out"];
}

#pragma mark - Voted For Dict

-(void)addToVotedForDictionary:(id)HNObject votedUp:(BOOL)up {
    NSString *objID, *direction;
    if ([HNObject isKindOfClass:[Post class]]) {
        objID = [(Post *)HNObject PostID];
    }
    else {
        objID = [(Comment *)HNObject CommentID];
    }
    
    direction = up ? @"UP" : @"DOWN";
    [self.votedForDictionary setValue:direction forKey:objID];
    [[NSUserDefaults standardUserDefaults] setObject:self.votedForDictionary forKey:@"VotedFor"];
}

-(BOOL)objectIsInVoteDict:(id)HNObject {
    NSString *objID;
    if ([HNObject isKindOfClass:[Post class]]) {
        objID = [(Post *)HNObject PostID];
    }
    else {
        objID = [(Comment *)HNObject CommentID];
    }
    if ([self.votedForDictionary objectForKey:objID]) {
        return YES;
    }
    
    return NO;
}

@end
