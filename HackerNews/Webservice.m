//
//  Webservice.m
//  HackerNews
//
//  Created by Benjamin Gordon with help by @MatthewYork on 4/28/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "Webservice.h"
#import "HNSingleton.h"
#import "HNOperation.h"

@implementation Webservice
@synthesize delegate;

-(id)init {
    self = [super init];
    self.HNOperationQueue = [[NSOperationQueue alloc] init];
    [self.HNOperationQueue setMaxConcurrentOperationCount:10];

    return self;
}

#pragma mark - Get Homepage
-(void)getHomepageWithSuccess:(GetHomeSuccessBlock)success failure:(GetHomeFailureBlock)failure {
    HNOperation *operation = [[HNOperation alloc] init];
    __weak HNOperation *weakOp = operation;
    [operation setUrlPath:@"https://www.hnsearch.com/bigrss" data:nil completion:^{
        NSString *responseString = [[NSString alloc] initWithData:weakOp.responseData encoding:NSStringEncodingConversionAllowLossy];
        if (responseString.length > 0) {
            // Parse String and grab IDs
            NSMutableArray *items = [@[] mutableCopy];
            NSArray *itemIDs = [responseString componentsSeparatedByString:@"<hnsearch_id>"];
            for (int xx = 1; xx < itemIDs.count; xx++) {
                NSString *idSubString = itemIDs[xx];
                [items addObject:[idSubString substringWithRange:NSMakeRange(0, 13)]];
            }
            
            // Make new request URL Path
            NSString *requestPath = @"http://api.thriftdb.com/api.hnsearch.com/items/_bulk/get_multi?ids=";
            for (NSString *item in items) {
                requestPath = [requestPath stringByAppendingString:[NSString stringWithFormat:@"%@,", item]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self grabPostsFromPath:requestPath items:items success:success failure:failure];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure();
            });
        }
    }];
    [self.HNOperationQueue addOperation:operation];
}

-(void)grabPostsFromPath:(NSString *)path items:(NSArray *)items success:(GetHomeSuccessBlock)success failure:(GetCommentsFailureBlock)failure {
    HNOperation *operation = [[HNOperation alloc] init];
    __weak HNOperation *weakOp = operation;
    [operation setUrlPath:path data:nil completion:^{
        NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:weakOp.responseData options:NSJSONReadingAllowFragments error:nil];
        if (responseArray) {
            NSMutableArray *postArray = [@[] mutableCopy];
            for (NSDictionary *dict in responseArray) {
                [postArray addObject:[Post postFromDictionary:dict]];
            }
            
            NSArray *orderedPostArray = [Post orderPosts:postArray byItemIDs:items];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                success(orderedPostArray);
                [self reloadUser];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure();
            });
            
        }
    }];
    [self.HNOperationQueue addOperation:operation];
}


#pragma mark - Get Comments
-(void)getCommentsForPost:(Post *)post success:(GetCommentsSuccessBlock)success failure:(GetCommentsFailureBlock)failure {
    HNOperation *operation = [[HNOperation alloc] init];
    __weak HNOperation *weakOp = operation;
    [operation setUrlPath:[NSString stringWithFormat:@"https://news.ycombinator.com/item?id=%@",post.hnPostID] data:nil completion:^{
        NSString *responseHTML = [[NSString alloc] initWithData:weakOp.responseData encoding:NSStringEncodingConversionAllowLossy];
        if (responseHTML.length > 0) {
            NSArray *comments = [Comment commentsFromHTML:responseHTML];
            dispatch_async(dispatch_get_main_queue(), ^{
                success(comments);
                [self reloadUser];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure();
            });
        }
    }];
    [self.HNOperationQueue addOperation:operation];
}


#pragma mark - Login
-(void)loginWithUsername:(NSString *)user password:(NSString *)pass {
    HNOperation *operation = [[HNOperation alloc] init];
    __weak HNOperation *weakOp = operation;
    [operation setUrlPath:@"https://news.ycombinator.com/newslogin?whence=news" data:nil completion:^{
        NSString *responseString = [[NSString alloc] initWithData:weakOp.responseData encoding:NSStringEncodingConversionAllowLossy];
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
    }];
    [self.HNOperationQueue addOperation:operation];
}

-(void)makeLoginRequestWithUser:(NSString *)user password:(NSString *)pass fnid:(NSString *)fnid {
    // Create BodyData
    NSString *bodyString = [NSString stringWithFormat:@"fnid=%@&u=%@&p=%@",fnid,user,pass];
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    // Make Request
    HNOperation *operation = [[HNOperation alloc] init];
    __weak HNOperation *weakOp = operation;
    [operation setUrlPath:@"https://news.ycombinator.com/y" data:bodyData completion:^{
        NSString *responseString = [[NSString alloc] initWithData:weakOp.responseData encoding:NSStringEncodingConversionAllowLossy];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ contains[c] SELF", responseString];
        if ([predicate evaluateWithObject:@"Bad login."]) {
            // Login Failed
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate webservice:self didLoginWithUser:nil];
            });
        }
        else {
            // Set Defaults
            [[NSUserDefaults standardUserDefaults] setValue:user forKey:@"Username"];
            [[NSUserDefaults standardUserDefaults] setValue:pass forKey:@"Password"];
            
            // Pass User through the delegate
            dispatch_async(dispatch_get_main_queue(), ^{
                [self createUser:user];
            });
        }
    }];
    [self.HNOperationQueue addOperation:operation];
}


#pragma mark - User
-(void)createUser:(NSString *)user {
    HNOperation *operation = [[HNOperation alloc] init];
    __weak HNOperation *weakOp = operation;
    [operation setUrlPath:[NSString stringWithFormat:@"https://news.ycombinator.com/user?id=%@", user] data:nil completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate webservice:self didLoginWithUser:[User userFromHTMLString:[[NSString alloc] initWithData:weakOp.responseData encoding:NSStringEncodingConversionAllowLossy]]];
        });
    }];
    [self.HNOperationQueue addOperation:operation];
}

-(void)reloadUser {
    if ([HNSingleton sharedHNSingleton].User) {
        HNOperation *operation = [[HNOperation alloc] init];
        __weak HNOperation *weakOp = operation;
        [operation setUrlPath:[NSString stringWithFormat:@"https://news.ycombinator.com/user?id=%@", [HNSingleton sharedHNSingleton].User.Username] data:nil completion:^{
            if (weakOp.responseData) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [HNSingleton sharedHNSingleton].User = [User userFromHTMLString:[[NSString alloc] initWithData:weakOp.responseData encoding:NSStringEncodingConversionAllowLossy]];
                    [HNSingleton sharedHNSingleton].User.Username = [[NSUserDefaults standardUserDefaults] valueForKey:@"Username"];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Failed
                });
            }
        }];
        [self.HNOperationQueue addOperation:operation];
    }
}


#pragma mark - Voting
-(void)voteUp:(BOOL)up forObject:(id)HNObject {
    // Get Voting ID
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
    
    // Make Request
    HNOperation *operation = [[HNOperation alloc] init];
    __weak HNOperation *weakOp = operation;
    [operation setUrlPath:[NSString stringWithFormat:@"https://news.ycombinator.com/item?id=%@",hnID] data:nil completion:^{
        NSString *responseString = [[NSString alloc] initWithData:weakOp.responseData encoding:NSStringEncodingConversionAllowLossy];
        if (responseString.length > 0) {
            // Create VoteURL
            NSScanner *scanner = [NSScanner scannerWithString:responseString];
            NSString *voteURL = @"";
            NSString *trash = @"";
            [scanner scanUpToString:[NSString stringWithFormat:@"id=up_%@", hnID] intoString:&trash];
            [scanner scanString:[NSString stringWithFormat:@"id=up_%@ onclick=\"return vote(this)\" href=\"", hnID] intoString:&trash];
            [scanner scanUpToString:@"\"" intoString:&voteURL];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self voteUp:up withPath:voteURL forObject:HNObject];
            });
        }
        else {
            // Voting failed
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate webservice:self didVoteWithSuccess:NO forObject:nil direction:NO];
            });
        }
    }];
    [self.HNOperationQueue addOperation:operation];
}

-(void)voteUp:(BOOL)up withPath:(NSString *)votePath forObject:(id)object {
    HNOperation *operation = [[HNOperation alloc] init];
    __weak HNOperation *weakOp = operation;
    [operation setUrlPath:[NSString stringWithFormat:@"https://news.ycombinator.com/%@", votePath] data:nil completion:^{
        NSString *responseString = [[NSString alloc] initWithData:weakOp.responseData encoding:NSStringEncodingConversionAllowLossy];
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
    }];
    [self.HNOperationQueue addOperation:operation];
}


#pragma mark - Submitting a Link
-(void)submitLink:(NSString *)urlPath orText:(NSString *)textPost title:(NSString *)title success:(SubmitLinkSuccessBlock)success failure:(SubmitLinkFailureBlock)failure {
    HNOperation *operation = [[HNOperation alloc] init];
    __weak HNOperation *weakOp = operation;
    [operation setUrlPath:@"https://news.ycombinator.com/submit" data:nil completion:^{
        NSString *responseString = [[NSString alloc] initWithData:weakOp.responseData encoding:NSStringEncodingConversionAllowLossy];
        if ([responseString rangeOfString:@"login"].location == NSNotFound) {
            NSString *trash = @"", *fnid = @"";
            NSScanner *scanner = [NSScanner scannerWithString:responseString];
            [scanner scanUpToString:@"name=\"fnid\" value=\"" intoString:&trash];
            [scanner scanString:@"name=\"fnid\" value=\"" intoString:&trash];
            [scanner scanUpToString:@"\"" intoString:&fnid];
            
            // Create BodyData
            NSString *bodyString;
            if (urlPath.length > 0) {
                bodyString = [NSString stringWithFormat:@"fnid=%@&u=%@&t=%@&x=\"\"", fnid, urlPath, title];
            }
            else {
                bodyString = [NSString stringWithFormat:@"fnid=%@&u=\"\"&t=%@&x=%@", fnid, title, textPost];
            }
            NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
            
            // Create next Request
            dispatch_async(dispatch_get_main_queue(), ^{
                [self submitData:bodyData success:success failure:failure];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure();
            });
        }
    }];
    [self.HNOperationQueue addOperation:operation];
}

-(void)submitData:(NSData *)bodyData success:(SubmitLinkSuccessBlock)success failure:(SubmitLinkFailureBlock)failure {
    HNOperation *operation = [[HNOperation alloc] init];
    __weak HNOperation *weakOp = operation;
    [operation setUrlPath:@"https://news.ycombinator.com/r" data:bodyData completion:^{
        NSString *responseString = [[NSString alloc] initWithData:weakOp.responseData encoding:NSStringEncodingConversionAllowLossy];
        if (responseString) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success();
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure();
            });
        }
    }];
    [self.HNOperationQueue addOperation:operation];
}


#pragma mark - Logging
-(void)logData:(NSData *)data {
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy]);
}

@end
