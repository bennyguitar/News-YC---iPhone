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

#import "HNWebService.h"
#import "HNManager.h"

#define kBaseURLAddress @"https://news.ycombinator.com/"
#define kCookieDomain @"news.ycombinator.com"
#define kMaxConcurrentConnections 15

#pragma mark - HNWebService
@implementation HNWebService

- (instancetype)init {
    if (self = [super init]) {
        self.HNQueue = [[NSOperationQueue alloc] init];
        [self.HNQueue setMaxConcurrentOperationCount:kMaxConcurrentConnections];
    }
    
    return self;
}


#pragma mark - Load Posts With Filter
- (void)loadPostsWithFilter:(PostFilterType)filter completion:(GetPostsCompletion)completion {
    // Set the Path
    NSString *pathAddition = @"";
    switch (filter) {
        case PostFilterTypeTop:
            pathAddition = @"";
            break;
        case PostFilterTypeAsk:
            pathAddition = @"ask";
            break;
        case PostFilterTypeBest:
            pathAddition = @"best";
            break;
        case PostFilterTypeJobs:
            pathAddition = @"jobs";
            break;
        case PostFilterTypeNew:
            pathAddition = @"newest";
            break;
        case PostFilterTypeShowHN:
            pathAddition = @"show";
            break;
        default:
            break;
    }
    NSString *urlPath = [NSString stringWithFormat:@"%@%@", kBaseURLAddress, pathAddition];
    
    // Load the Posts
    HNOperation *operation = [[HNOperation alloc] init];
    __block HNOperation *blockOperation = operation;
    [operation setUrlPath:urlPath data:nil cookie:[HNManager sharedManager].SessionCookie completion:^{
        if (blockOperation.responseData) {
            NSString *html = [[NSString alloc] initWithData:blockOperation.responseData encoding:NSUTF8StringEncoding];
            NSString *fnid = @"";
            NSArray *posts = [HNPost parsedPostsFromHTML:html FNID:&fnid];
            if (posts) {
                [[HNManager sharedManager] setPostUrlAddition:fnid];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(posts, fnid);
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, nil);
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil);
            });
        }
    }];
    [self.HNQueue addOperation:operation];
}


#pragma mark - Load Posts with FNID
- (void)loadPostsWithUrlAddition:(NSString *)urlAddition completion:(GetPostsCompletion)completion {
    if (!urlAddition || urlAddition.length == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(@[], nil);
        });
        return;
    }
    
    // Create URL Path
    NSString *urlPath = [NSString stringWithFormat:@"%@%@", kBaseURLAddress, urlAddition];
    
    // Load the Posts
    HNOperation *operation = [[HNOperation alloc] init];
    __block HNOperation *blockOperation = operation;
    [operation setUrlPath:urlPath data:nil cookie:[HNManager sharedManager].SessionCookie completion:^{
        if (blockOperation.responseData) {
            NSString *html = [[NSString alloc] initWithData:blockOperation.responseData encoding:NSUTF8StringEncoding];
            NSString *fnid = @"";
            NSArray *posts = [HNPost parsedPostsFromHTML:html FNID:&fnid];
            if (posts) {
                [[HNManager sharedManager] setPostUrlAddition:fnid];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(posts, fnid);
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, nil);
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil);
            });
        }
    }];
    [self.HNQueue addOperation:operation];
}


#pragma mark - Load Comments from Post
- (void)loadCommentsFromPost:(HNPost *)post completion:(GetCommentsCompletion)completion {
    // Create URL Path
    NSString *urlPath = [NSString stringWithFormat:@"%@item?id=%@", kBaseURLAddress, post.PostId];
    
    // Load the Comments
    HNOperation *operation = [[HNOperation alloc] init];
    __block HNOperation *blockOperation = operation;
    [operation setUrlPath:urlPath data:nil cookie:[HNManager sharedManager].SessionCookie completion:^{
        if (blockOperation.responseData) {
            NSString *html = [[NSString alloc] initWithData:blockOperation.responseData encoding:NSUTF8StringEncoding];
            NSArray *comments = [HNComment parsedCommentsFromHTML:html forPost:post];
            if (comments) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(comments);
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil);
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
    }];
    [self.HNQueue addOperation:operation];
}


#pragma mark - Login
- (void)loginWithUsername:(NSString *)user pass:(NSString *)pass completion:(LoginCompletion)completion {
    // Now let's attempt to login
    NSString *urlPath = [NSString stringWithFormat:@"%@login", kBaseURLAddress];
    
    // Build the body data
    NSString *bodyString = [NSString stringWithFormat:@"acct=%@&pw=%@&whence=news",user,pass];
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    // Start the Operation
    HNOperation *operation = [[HNOperation alloc] init];
    __block HNOperation *blockOperation = operation;
    [operation setUrlPath:urlPath data:bodyData cookie:nil completion:^{
        if (blockOperation.responseData) {
            // Now attempt part 3
            NSString *responseString = [[NSString alloc] initWithData:blockOperation.responseData encoding:NSUTF8StringEncoding];
            if (responseString) {
                if ([responseString rangeOfString:@">Bad login."].location == NSNotFound && [responseString rangeOfString:@"Unknown or expired link."].location == NSNotFound) {
                    
                    NSString *trash=@"", *karma=@"";
                    NSScanner *scanner = [NSScanner scannerWithString:responseString];
                    [scanner scanUpToString:@"/a>&nbsp;(" intoString:&trash];
                    [scanner scanString:@"/a>&nbsp;(" intoString:&trash];
                    [scanner scanUpToString:@")" intoString:&karma];
                    
                    // Login Succeded
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self getLoggedInUser:user karma:[karma intValue] completion:completion];
                    });
                }
                else {
                    // Login failed
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil,nil);
                    });
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil,nil);
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil,nil);
            });
        }
    }];
    [self.HNQueue addOperation:operation];
}

- (void)getLoggedInUser:(NSString *)user karma:(int)karma completion:(LoginCompletion)completion {
    // And finally we attempt to create the User
    // Build URL String
    NSString *urlPath = [NSString stringWithFormat:@"%@user?id=%@", kBaseURLAddress, user];
    
    // Start the Operation
    HNOperation *operation = [[HNOperation alloc] init];
    __block HNOperation *blockOperation = operation;
    [operation setUrlPath:urlPath data:nil cookie:nil completion:^{
        if (blockOperation.responseData) {
            // Now attempt part 3
            NSString *html = [[NSString alloc] initWithData:blockOperation.responseData encoding:NSUTF8StringEncoding];
            if (html) {
                HNUser *hnUser;
                NSHTTPCookie *Cookie;
                if ([html rangeOfString:@"We've limited requests for this url."].location == NSNotFound) {
                    hnUser = [HNUser userFromHTML:html];
                }
                else {
                    hnUser = [[HNUser alloc] init];
                    hnUser.Username = user;
                    hnUser.Karma = karma ? karma : 0;
                }
                
                Cookie = [HNManager getHNCookie];
                
                if (user) {
                    // Finally return the user we've been looking for
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(hnUser, Cookie);
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil, nil);
                    });
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, nil);
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil);
            });
        }
    }];
    [self.HNQueue addOperation:operation];
}


#pragma mark - Validate Session Cookie
- (void)validateAndSetSessionWithCookie:(NSHTTPCookie *)cookie completion:(LoginCompletion)completion {
    // And finally we attempt to create the User
    // Build URL String
    NSString *urlPath = [NSString stringWithFormat:@"%@user?id=pg", kBaseURLAddress];
    
    // Start the Operation
    HNOperation *operation = [[HNOperation alloc] init];
    __block HNOperation *blockOperation = operation;
    [operation setUrlPath:urlPath data:nil cookie:cookie completion:^{
        if (blockOperation.responseData) {
            // Now attempt part 3
            NSString *html = [[NSString alloc] initWithData:blockOperation.responseData encoding:NSUTF8StringEncoding];
            if (html) {
                if ([html rangeOfString:@"<a href=\"logout"].location != NSNotFound) {
                    NSScanner *scanner = [[NSScanner alloc] initWithString:html];
                    NSString *trash = @"", *userString = @"", *karma=@"";
                    [scanner scanUpToString:@"<a href=\"threads?id=" intoString:&trash];
                    [scanner scanString:@"<a href=\"threads?id=" intoString:&trash];
                    [scanner scanUpToString:@"\">" intoString:&userString];
                    [scanner scanUpToString:@"&nbsp;(" intoString:&trash];
                    [scanner scanString:@"&nbsp;(" intoString:&trash];
                    [scanner scanUpToString:@")" intoString:&karma];
                    [self getLoggedInUser:userString karma:[karma intValue] completion:completion];
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil, nil);
                    });
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, nil);
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil);
            });
        }
    }];
    [self.HNQueue addOperation:operation];
}


#pragma mark - Submit Post
- (void)submitPostWithTitle:(NSString *)title link:(NSString *)link text:(NSString *)text completion:(BooleanSuccessBlock)completion {
    // Submitting a post is a two=part process
    // 1. Get the fnid of the Submission page
    // 2. Submit the link/text using the fnid
    
    // if no Cookie, we can't submit
    if (![[HNManager sharedManager] SessionCookie]) {
        completion(NO);
        return;
    }
    
    // Make the url path
    NSString *urlPath = [NSString stringWithFormat:@"%@submit", kBaseURLAddress];
    
    // Start the Operation
    HNOperation *operation = [[HNOperation alloc] init];
    __block HNOperation *blockOperation = operation;
    [operation setUrlPath:urlPath data:nil cookie:[[HNManager sharedManager] SessionCookie] completion:^{
        if (blockOperation.responseData) {
            NSString *html = [[NSString alloc] initWithData:blockOperation.responseData encoding:NSUTF8StringEncoding];
            if ([html rangeOfString:@"login"].location == NSNotFound) {
                NSString *trash = @"", *fnid = @"";
                NSScanner *scanner = [NSScanner scannerWithString:html];
                [scanner scanUpToString:@"name=\"fnid\" value=\"" intoString:&trash];
                [scanner scanString:@"name=\"fnid\" value=\"" intoString:&trash];
                [scanner scanUpToString:@"\"" intoString:&fnid];
                
                if (fnid.length > 0) {
                    // Create BodyData
                    NSString *bodyString;
                    if (link.length > 0) {
                        bodyString = [[NSString stringWithFormat:@"fnid=%@&u=%@&t=%@&x=", fnid, link, title] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    }
                    else {
                        bodyString = [[NSString stringWithFormat:@"fnid=%@&u=&t=%@&x=%@", fnid, title, text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    }
                    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
                    
                    // Create next Request
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self part2SubmitPostOrCommentWithData:bodyData pathComponent:@"r" completion:completion];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(NO);
                    });
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO);
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }
    }];
    [self.HNQueue addOperation:operation];
}

#pragma mark - Reply to Post/Comment
- (void)replyToHNObject:(id)hnObject withText:(NSString *)text completion:(BooleanSuccessBlock)completion {
    // Submitting a comment is a two-part
    // 1. Get the fnid of the Reply page
    // 2. Submit the link/text using the fnid
    
    // if no Cookie, we can't submit
    if (![[HNManager sharedManager] SessionCookie]) {
        completion(NO);
        return;
    }
    
    // Get itemId
    NSString *itemId;
    if ([hnObject isKindOfClass:[HNPost class]]) {
        itemId = [(HNPost *)hnObject PostId];
    }
    else {
        itemId = [(HNComment *)hnObject CommentId];
    }
    
    // Make the url path
    NSString *urlPath = [NSString stringWithFormat:@"%@reply?id=%@", kBaseURLAddress, itemId];
    
    // Start the Operation
    HNOperation *operation = [[HNOperation alloc] init];
    __block HNOperation *blockOperation = operation;
    [operation setUrlPath:urlPath data:nil cookie:[[HNManager sharedManager] SessionCookie] completion:^{
        if (blockOperation.responseData) {
            NSString *html = [[NSString alloc] initWithData:blockOperation.responseData encoding:NSUTF8StringEncoding];
            if ([html rangeOfString:@"textarea"].location != NSNotFound) {
                NSString *trash = @"", *hmac = @"", *parent, *whence;
                NSScanner *scanner = [NSScanner scannerWithString:html];
                
                [scanner scanUpToString:@"name=\"parent\" value=\"" intoString:&trash];
                [scanner scanString:@"name=\"parent\" value=\"" intoString:&trash];
                [scanner scanUpToString:@"\"" intoString:&parent];
                
                [scanner scanUpToString:@"name=\"whence\" value=\"" intoString:&trash];
                [scanner scanString:@"name=\"whence\" value=\"" intoString:&trash];
                [scanner scanUpToString:@"\"" intoString:&whence];
                
                [scanner scanUpToString:@"name=\"hmac\" value=\"" intoString:&trash];
                [scanner scanString:@"name=\"hmac\" value=\"" intoString:&trash];
                [scanner scanUpToString:@"\"" intoString:&hmac];
                
                if (hmac.length > 0) {
                    // Create BodyData
                    NSString *bodyString = [[NSString stringWithFormat:@"hmac=%@&text=%@&parent=%@&whence=%@", hmac, text, parent, whence] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
                    
                    // Create next Request
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self part2SubmitPostOrCommentWithData:bodyData pathComponent:@"comment" completion:completion];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(NO);
                    });
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO);
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }
    }];
    [self.HNQueue addOperation:operation];
}


#pragma mark - Part 2 of submitting a Comment/Post
- (void)part2SubmitPostOrCommentWithData:(NSData *)bodyData pathComponent:(NSString *)pathComponent completion:(BooleanSuccessBlock)completion {
    // Make the url path
    NSString *urlPath = [NSString stringWithFormat:@"%@%@", kBaseURLAddress, pathComponent];
    
    // Start the Operation
    HNOperation *operation = [[HNOperation alloc] init];
    __block HNOperation *blockOperation = operation;
    [operation setUrlPath:urlPath data:bodyData cookie:[[HNManager sharedManager] SessionCookie] completion:^{
        if (blockOperation.responseData) {
            NSString *html = [[NSString alloc] initWithData:blockOperation.responseData encoding:NSUTF8StringEncoding];
            if ([html rangeOfString:@"logout?whence=%6e%65%77%65%73%74"].location != NSNotFound || [html rangeOfString:@"logout?whence=%6e%65%77%73"].location != NSNotFound) {
                // It worked!
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES);
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO);
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }
    }];
    [self.HNQueue addOperation:operation];
}



#pragma mark - Vote on Post/Comment
- (void)voteOnHNObject:(id)hnObject direction:(VoteDirection)direction completion:(BooleanSuccessBlock)completion {
    // Voting is a two part process
    // 1. Grab the voting string associated with the direction (vote?for=6510488&amp;dir=up&amp;by=bennyg&amp;auth=69984d18a11d7f663259e6bd203791acd284978e)
    // 2. Call that HTML and check for errors
    
    // if no Cookie, we can't vote
    if (![[HNManager sharedManager] SessionCookie]) {
        completion(NO);
        return;
    }
    
    // Get urlAddition
    NSString *urlAddition;
    NSString *uniqueId;
    if ([hnObject isKindOfClass:[HNPost class]]) {
        if (direction == VoteDirectionDown) {
            // You can't downvote a Post
            completion(NO);
            return;
        }
        urlAddition = [(HNPost *)hnObject UpvoteURLAddition];
        uniqueId = [(HNPost *)hnObject PostId];
    }
    else {
        urlAddition = direction == VoteDirectionUp ? [(HNComment *)hnObject UpvoteURLAddition] : [(HNComment *)hnObject DownvoteURLAddition];
        uniqueId = [(HNComment *)hnObject CommentId];
    }
    
    // if urlAddition is nil, return
    if (!urlAddition) {
        completion(NO);
        return;
    }
    
    // Make the url path
    NSString *urlPath = [[NSString stringWithFormat:@"%@%@", kBaseURLAddress, urlAddition] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    
    // Start the Operation
    HNOperation *operation = [[HNOperation alloc] init];
    __block HNOperation *blockOperation = operation;
    [operation setUrlPath:urlPath data:nil cookie:[[HNManager sharedManager] SessionCookie] completion:^{
        if (blockOperation.responseData) {
            NSString *html = [[NSString alloc] initWithData:blockOperation.responseData encoding:NSUTF8StringEncoding];
            if ([html rangeOfString:[NSString stringWithFormat:@"for=%@", uniqueId]].location == NSNotFound) {
                // It worked!
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES);
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO);
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }
    }];
    [self.HNQueue addOperation:operation];
}


#pragma mark - Fetch Submissions
- (void)fetchSubmissionsForUser:(NSString *)user urlAddition:(NSString *)urlAddition completion:(GetPostsCompletion)completion {
    // Make the url path
    NSString *urlPath;
    if (urlAddition) {
        urlPath = [NSString stringWithFormat:@"%@%@", kBaseURLAddress, urlAddition];
    }
    else {
        urlPath = [NSString stringWithFormat:@"%@submitted?id=%@", kBaseURLAddress, user];
    }
    
    // Start the Operation
    HNOperation *operation = [[HNOperation alloc] init];
    __block HNOperation *blockOperation = operation;
    [operation setUrlPath:urlPath data:nil cookie:[[HNManager sharedManager] SessionCookie] completion:^{
        if (blockOperation.responseData) {
            NSString *html = [[NSString alloc] initWithData:blockOperation.responseData encoding:NSUTF8StringEncoding];
            if ([html rangeOfString:@"No such user."].location != NSNotFound && html.length == 13) {
                // Bad Request
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, nil);
                });
            }
            else {
                NSString *fnid = @"";
                NSArray *posts = [HNPost parsedPostsFromHTML:html FNID:&fnid];
                [[HNManager sharedManager] setUserSubmissionUrlAddition:fnid];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(posts, fnid);
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil);
            });
        }
    }];
    [self.HNQueue addOperation:operation];
}


- (void)cancelAllRequests {
    for (HNOperation *operation in self.HNQueue.operations) {
        [operation cancel];
    }
}


@end






#pragma mark - HNOperation
@implementation HNOperation

#pragma mark - Set URL Path
-(void)setUrlPath:(NSString *)path data:(NSData *)data cookie:(NSHTTPCookie *)cookie completion:(void (^)(void))block {
    if (data) {
        self.bodyData = data;
    }
    if (self.bodyData) {
        self.urlRequest = [HNOperation newJSONRequestWithURL:[NSURL URLWithString:path] bodyData:self.bodyData cookie:cookie];
    }
    else {
        self.urlRequest = [HNOperation newGetRequestForURL:[NSURL URLWithString:path] cookie:cookie];
    }
    
    // Set Completion Block
    [self setCompletionBlock:block];
}


#pragma mark - Background
-(BOOL)isConcurrent {
    return YES;
}


#pragma mark - Main Run Loop
-(void)main {
    // Execute
    NSError *error;
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
    self.responseData = [NSURLConnection sendSynchronousRequest:self.urlRequest returningResponse:&response error:&error];
    self.response = response;
}

#pragma mark - URL Request Building
+(NSMutableURLRequest *)newGetRequestForURL:(NSURL *)url cookie:(NSHTTPCookie *)cookie {
    NSMutableURLRequest *Request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [Request setHTTPShouldHandleCookies:NO];
    [Request setHTTPMethod:@"GET"];
    [Request setAllHTTPHeaderFields:@{}];
    
    if (cookie) {
        NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:@[cookie]];
        [Request setAllHTTPHeaderFields:headers];
    }
    
    return Request;
}

+(NSMutableURLRequest *)newJSONRequestWithURL:(NSURL *)url bodyData:(NSData *)bodyData cookie:(NSHTTPCookie *)cookie {
    NSMutableURLRequest *Request = [[NSMutableURLRequest alloc] initWithURL:url];
    [Request setHTTPMethod:@"POST"];
    //[Request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //[Request setValue:@(bodyData.length) forKey:@"Content-Length"];
    [Request setHTTPBody:bodyData];
    [Request setHTTPShouldHandleCookies:YES];
    [Request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [Request setAllHTTPHeaderFields:@{}];
    
    if (cookie) {
        NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:@[cookie]];
        [Request setAllHTTPHeaderFields:headers];
    }
    
    return Request;
}

@end
