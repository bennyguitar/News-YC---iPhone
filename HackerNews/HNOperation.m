//
//  HNOperation.m
//  HackerNews
//
//  Created by Ben Gordon on 7/13/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "HNOperation.h"

@implementation HNOperation

#pragma mark - Init
-(void)setUrlPath:(NSString *)path data:(NSData *)data completion:(void (^)(void))block {
    self.urlPath = path;
    [self setCompletionBlock:block];
    if (data) {
        self.bodyData = data;
    }
}

#pragma mark - Background It
-(BOOL)isConcurrent {
    return YES;
}

#pragma mark - Run it
-(void)main {
    // Build Request
    NSMutableURLRequest *request;
    if (self.bodyData) {
        request = [HNOperation newJSONRequestWithURL:[NSURL URLWithString:self.urlPath] bodyData:self.bodyData];
    }
    else {
        request = [HNOperation newGetRequestForURL:[NSURL URLWithString:self.urlPath]];
    }
    
    // Execute
    NSError *error;
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
    self.responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
}

#pragma mark - URL Request Building
+(NSMutableURLRequest *)newGetRequestForURL:(NSURL *)url {
    NSMutableURLRequest *Request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLCacheStorageAllowedInMemoryOnly timeoutInterval:10];
    [Request setHTTPMethod:@"GET"];
    
    return Request;
}

+(NSMutableURLRequest *)newJSONRequestWithURL:(NSURL *)url bodyData:(NSData *)bodyData{
    NSMutableURLRequest *Request = [[NSMutableURLRequest alloc] initWithURL:url];
    [Request setHTTPMethod:@"POST"];
    [Request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [Request setHTTPBody:bodyData];
    [Request setHTTPShouldHandleCookies:YES];
    [Request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    
    return Request;
}

@end
