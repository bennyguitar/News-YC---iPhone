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

@protocol WebserviceDelegate
@optional

-(void)didFetchPosts:(NSArray *)posts;
-(void)didFetchComments:(NSArray *)comments;

@end

@interface Webservice : NSObject {
    __weak id <WebserviceDelegate> delegate;
}
//Delegate
@property (weak) id <WebserviceDelegate> delegate;

// Methods
-(void)getHomepage;
-(void)getCommentsForPost:(Post *)post;

@end
