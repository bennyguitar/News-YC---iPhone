//
//  ViewController.m
//  HackerNews
//
//  Created by Benjamin Gordon on 5/1/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadHomepage];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Load HomePage
-(void)loadHomepage {
    Webservice *service = [[Webservice alloc] init];
    service.delegate = self;
    [service getHomepage];
}

-(void)didFetchPosts:(NSArray *)posts {
    if (posts) {
        // Handle
    }
    else {
        // No posts were retrieved. Handle exception.
    }
}

#pragma mark - Load Comments
-(void)loadCommentsForPost:(Post *)post {
    Webservice *service = [[Webservice alloc] init];
    service.delegate = self;
    [service getCommentsForPost:post];
}

-(void)didFetchComments:(NSArray *)comments {
    if (comments) {
        
    }
    else {
        // No comments were retrieved. Handle exception.
    }
}

@end
