//
//  Webservice.m
//  HackerNews
//
//  Created by Benjamin Gordon with help by @MatthewYork on 4/28/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "Webservice.h"
#import "HNSingleton.h"

@implementation Webservice
@synthesize delegate;

#pragma mark - Get Homepage
-(void)getHomepage {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSURLResponse *response;
        NSError *error;
        
        // Create the URL Request
        NSMutableURLRequest *request = [Webservice NewGetRequestForURL:[NSURL URLWithString:@"https://www.hnsearch.com/bigrss"]];
        
        // Start the request
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        
        //Handle response
        //Callback to main thread
        if (responseData) {
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSStringEncodingConversionAllowLossy];
            //[self logData:responseData];
            if (responseString.length > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self parseIDsAndGrabPosts:responseString];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate webservice:self didFetchPosts:nil];
                });
                
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate webservice:self didFetchPosts:nil];
            });
        }
        
        
    });
}


-(void)parseIDsAndGrabPosts:(NSString *)parseString {
    // Parse String and grab IDs
    NSMutableArray *items = [@[] mutableCopy];
    NSArray *itemIDs = [parseString componentsSeparatedByString:@"<hnsearch_id>"];
    for (int xx = 1; xx < itemIDs.count; xx++) {
        NSString *idSubString = itemIDs[xx];
        [items addObject:[idSubString substringWithRange:NSMakeRange(0, 13)]];
    }
    
    
    // Send IDs back to HNSearch for Posts
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSURLResponse *response;
        NSError *error;
        
        // Create Request String
        NSString *requestString = @"http://api.thriftdb.com/api.hnsearch.com/items/_bulk/get_multi?ids=";
        for (NSString *item in items) {
            requestString = [requestString stringByAppendingString:[NSString stringWithFormat:@"%@,", item]];
        }
        
        // Create the URL Request
        NSMutableURLRequest *request = [Webservice NewGetRequestForURL:[NSURL URLWithString:requestString]];
        
        // Start the request
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        
        //Handle response
        //Callback to main thread
        if (responseData) {
            NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
            [self logData:responseData];
            if (responseArray) {
                NSMutableArray *postArray = [@[] mutableCopy];
                for (NSDictionary *dict in responseArray) {
                    [postArray addObject:[Post postFromDictionary:dict]];
                }
                
                NSArray *orderedPostArray = [self orderPosts:postArray byItemIDs:items];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate webservice:self didFetchPosts:orderedPostArray];
                    
                    // Update Karma for User
                    if ([HNSingleton sharedHNSingleton].User) {
                        [self reloadUserFromURLString:[NSString stringWithFormat:@"https://news.ycombinator.com/user?id=%@", [HNSingleton sharedHNSingleton].User.Username]];
                    }
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate webservice:self didFetchPosts:nil];
                });
                
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate webservice:self didFetchPosts:nil];
            });
        }
        
        
    });
}

-(NSArray *)orderPosts:(NSMutableArray *)posts byItemIDs:(NSArray *)items {
    NSMutableArray *orderedPosts = [@[] mutableCopy];
    
    for (NSString *itemID in items) {
        for (Post *post in posts) {
            if ([post.PostID isEqualToString:itemID]) {
                [orderedPosts addObject:post];
                [posts removeObject:post];
                break;
            }
        }
    }
    
    return orderedPosts;
}


#pragma mark - Get Comments
-(void)getCommentsForPost:(Post *)post launchComments:(BOOL)launch {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSURLResponse *response;
        NSError *error;
        
        // Create the URL Request
        NSMutableURLRequest *request = [Webservice NewGetRequestForURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][discussion.sigid]=%@&limit=100&start=0&sortby=points%%20asc",post.PostID]]];
        
        // Start the request
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        // Handle response
        // Callback to main thread
        if (responseData) {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
            //[self logData:responseData];
            if ([responseDict objectForKey:@"results"]) {
                NSMutableArray *comments = [@[] mutableCopy];
                NSArray *commentDicts = [responseDict objectForKey:@"results"];
                for (NSDictionary *comment in commentDicts) {
                    [comments addObject:[Comment commentFromDictionary:[comment objectForKey:@"item"]]];
                }
                
                NSArray *orderedComments = [Comment organizeComments:comments topLevelID:post.PostID];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate webservice:self didFetchComments:orderedComments forPostID:post.PostID launchComments:launch];
                    
                    // Update Karma for User
                    if ([HNSingleton sharedHNSingleton].User) {
                        [self reloadUserFromURLString:[NSString stringWithFormat:@"https://news.ycombinator.com/user?id=%@", [HNSingleton sharedHNSingleton].User.Username]];
                    }
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate webservice:self didFetchComments:nil forPostID:nil launchComments:NO];
                });
                
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate webservice:self didFetchComments:nil forPostID:nil launchComments:NO];
            });
        }
        
        
    });
}

#pragma mark - Login
-(void)loginWithUsername:(NSString *)user password:(NSString *)pass {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSURLResponse *response;
        NSError *error;
        
        // Create the URL Request
        NSMutableURLRequest *request = [Webservice NewGetRequestForURL:[NSURL URLWithString:@"https://news.ycombinator.com/newslogin?whence=news"]];
        
        // Start the request
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        
        //Handle response
        //Callback to main thread
        if (responseData) {
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSStringEncodingConversionAllowLossy];
            
            if (responseString.length > 0) {
                NSString *fnid = @"", *trash = @"";
                NSScanner *fnidScan = [NSScanner scannerWithString:responseString];
                [fnidScan scanUpToString:@"name=\"fnid\" value=\"" intoString:&trash];
                [fnidScan scanString:@"name=\"fnid\" value=\"" intoString:&trash];
                [fnidScan scanUpToString:@"\"" intoString:&fnid];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (fnid.length > 0) {
                        [self makeLoginRequestWithUser:user password:pass fnid:fnid];
                    }
                    else {
                        [delegate webservice:self didLoginWithUser:nil];
                    }
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate webservice:self didLoginWithUser:nil];
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate webservice:self didLoginWithUser:nil];
            });
        }
    });
}

-(void)makeLoginRequestWithUser:(NSString *)user password:(NSString *)pass fnid:(NSString *)fnid {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
        NSError *error;
        
        NSString *bodyString = [NSString stringWithFormat:@"fnid=%@&u=%@&p=%@",fnid,user,pass];
        NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
        
        // Create the URL Request
        NSMutableURLRequest *request = [Webservice NewJSONRequestWithURL:[NSURL URLWithString:@"https://news.ycombinator.com/y"] bodyData:bodyData];
        
        // Start the request
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        
        //Handle response
        //Callback to main thread
        if (responseData) {
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSStringEncodingConversionAllowLossy];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ contains[c] SELF", responseString];
            if ([predicate evaluateWithObject:@">Bad login."]) {
                // Login Failed
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate webservice:self didLoginWithUser:nil];
                });
            }
            else {
                // Set Defaults
                [[NSUserDefaults standardUserDefaults] setValue:user forKey:@"Username"];
                [[NSUserDefaults standardUserDefaults] setValue:pass forKey:@"Password"];
                
                // Save Cookie
                [[HNSingleton sharedHNSingleton] setSession];
                
                // Pass User through the delegate
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self createUserFromURLString:[NSString stringWithFormat:@"https://news.ycombinator.com/user?id=%@", user]];
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate webservice:self didLoginWithUser:nil];
            });
        }
    });
}

-(void)createUserFromURLString:(NSString *)urlString {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
        NSError *error;
        
        // Create the URL Request
        NSMutableURLRequest *request = [Webservice NewGetRequestForURL:[NSURL URLWithString:urlString]];
        [request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:@[[HNSingleton sharedHNSingleton].SessionCookie]]];
        
        // Start the request
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        //Handle response
        //Callback to main thread
        if (responseData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate webservice:self didLoginWithUser:[User userFromHTMLString:[[NSString alloc] initWithData:responseData encoding:NSStringEncodingConversionAllowLossy]]];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate webservice:self didLoginWithUser:nil];
            });
        }
    });
}

-(void)reloadUserFromURLString:(NSString *)urlString {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
        NSError *error;
        
        // Create the URL Request
        NSMutableURLRequest *request = [Webservice NewGetRequestForURL:[NSURL URLWithString:urlString]];
        [request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:@[[HNSingleton sharedHNSingleton].SessionCookie]]];
        
        // Start the request
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        //Handle response
        //Callback to main thread
        if (responseData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [HNSingleton sharedHNSingleton].User = [User userFromHTMLString:[[NSString alloc] initWithData:responseData encoding:NSStringEncodingConversionAllowLossy]];
                [HNSingleton sharedHNSingleton].User.Username = [[NSUserDefaults standardUserDefaults] valueForKey:@"Username"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DidLoginOrOut" object:nil];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                // Failed
            });
        }
    });
}

#pragma mark - Voting
-(void)voteUp:(BOOL)up forObject:(id)HNObject {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
        NSError *error;
        
        // Get ID
        NSString *hnID = @"";
        if ([HNObject isKindOfClass:[Post class]]) {
            Post *post = (Post *)HNObject;
            hnID = post.hnPostID;
        }
        else if ([HNObject isKindOfClass:[Comment class]]) {
            Comment *com = (Comment *)HNObject;
            hnID = com.hnCommentID;
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate webservice:self didVoteWithSuccess:NO forObject:nil direction:NO];
                return;
            });
        }
        
        // Create the URL Request
        NSMutableURLRequest *request = [Webservice NewGetRequestForURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://news.ycombinator.com/item?id=%@",hnID]]];
        [request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:@[[HNSingleton sharedHNSingleton].SessionCookie]]];
        
        // Start the request
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        
        //Handle response
        //Callback to main thread
        if (responseData) {
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSStringEncodingConversionAllowLossy];
            
            if (responseString.length > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self voteUp:up withIDString:hnID inHTMLString:responseString forObject:HNObject];
                });
            }
            else {
                // Voting failed
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate webservice:self didVoteWithSuccess:NO forObject:nil direction:NO];
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate webservice:self didVoteWithSuccess:NO forObject:nil direction:NO];
            });
        }
    });
}


-(void)voteUp:(BOOL)up withIDString:(NSString *)idString inHTMLString:(NSString *)htmlString forObject:(id)object {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
        NSError *error;
        
        NSScanner *scanner = [NSScanner scannerWithString:htmlString];
        NSString *voteURL = @"";
        NSString *trash = @"";
        [scanner scanUpToString:[NSString stringWithFormat:@"id=up_%@", idString] intoString:&trash];
        [scanner scanString:[NSString stringWithFormat:@"id=up_%@ onclick=\"return vote(this)\" href=\"", idString] intoString:&trash];
        [scanner scanUpToString:@"\"" intoString:&voteURL];
        
        // Create the URL Request
        NSMutableURLRequest *request = [Webservice NewGetRequestForURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://news.ycombinator.com/%@",voteURL]]];
        [request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:@[[HNSingleton sharedHNSingleton].SessionCookie]]];
        
        // Start the request
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        
        //Handle response
        //Callback to main thread
        if (responseData) {
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSStringEncodingConversionAllowLossy];
            
            if (responseString) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate webservice:self didVoteWithSuccess:YES forObject:object direction:up];
                });
            }
            else {
                // Voting failed
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate webservice:self didVoteWithSuccess:NO forObject:nil direction:up];
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate webservice:self didVoteWithSuccess:NO forObject:nil direction:up];
            });
        }
    });
}


////////////////////////////////////////////////////

#pragma mark - URL Request
+(NSMutableURLRequest *)NewGetRequestForURL:(NSURL *)url {
    NSMutableURLRequest *Request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLCacheStorageAllowedInMemoryOnly timeoutInterval:10];
    [Request setHTTPMethod:@"GET"];
    
    return Request;
}

+(NSMutableURLRequest *)NewJSONRequestWithURL:(NSURL *)url bodyData:(NSData *)bodyData{
    NSMutableURLRequest *Request = [[NSMutableURLRequest alloc] initWithURL:url];
    [Request setHTTPMethod:@"POST"];
    [Request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [Request setHTTPBody:bodyData];
    [Request setHTTPShouldHandleCookies:YES];
    [Request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    
    return Request;
}

////////////////////////////////////////////////////

#pragma mark - Logging
-(void)logData:(NSData *)data {
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy]);
}

@end
