//
//  Webservice.m
//  HackerNews
//
//  Created by Benjamin Gordon with help by @MatthewYork on 4/28/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "Webservice.h"

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
            
            if (responseString.length > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self parseIDsAndGrabPosts:responseString];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate didFetchPosts:nil];
                });
                
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate didFetchPosts:nil];
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
            
            if (responseArray) {
                NSMutableArray *postArray = [@[] mutableCopy];
                for (NSDictionary *dict in responseArray) {
                    [postArray addObject:[Post postFromDictionary:dict]];
                }
                
                NSArray *orderedPostArray = [self orderPosts:postArray byItemIDs:items];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate didFetchPosts:orderedPostArray];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate didFetchPosts:nil];
                });
                
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate didFetchPosts:nil];
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
        NSMutableURLRequest *request = [Webservice NewGetRequestForURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][discussion.sigid]=%@&limit=100&start=0&sortby=parent_id",post.PostID]]];
        
        // Start the request
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        // Handle response
        // Callback to main thread
        if (responseData) {
           NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
            
            if ([responseDict objectForKey:@"results"]) {
                NSMutableArray *comments = [@[] mutableCopy];
                NSArray *commentDicts = [responseDict objectForKey:@"results"];
                for (NSDictionary *comment in commentDicts) {
                    [comments addObject:[Comment commentFromDictionary:[comment objectForKey:@"item"]]];
                }
                
                NSArray *orderedComments = [Comment organizeComments:comments topLevelID:post.PostID];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate didFetchComments:orderedComments forPostID:post.PostID launchComments:launch];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate didFetchComments:nil forPostID:nil launchComments:NO];
                });
                
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate didFetchComments:nil forPostID:nil launchComments:NO];
            });
        }
        
        
    });
}

#pragma mark - URL Request
+(NSMutableURLRequest *)NewGetRequestForURL:(NSURL *)url {
    NSMutableURLRequest *Request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:10];
    [Request setHTTPMethod:@"GET"];
    
    return Request;
}

@end
