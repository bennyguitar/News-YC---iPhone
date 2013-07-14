//
//  HNOperation.h
//  HackerNews
//
//  Created by Ben Gordon on 7/13/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNOperation : NSOperation

@property (nonatomic, retain) NSString *urlPath;
@property (nonatomic, retain) NSData *bodyData;
@property (nonatomic, retain) NSData *responseData;

// Init
-(void)setUrlPath:(NSString *)path data:(NSData *)data completion:(void (^)(void))block;

// Web Request Builders
+(NSMutableURLRequest *)newGetRequestForURL:(NSURL *)url;
+(NSMutableURLRequest *)newJSONRequestWithURL:(NSURL *)url bodyData:(NSData *)bodyData;

@end
