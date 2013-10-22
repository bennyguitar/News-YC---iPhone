//
//  HNUser.h
//  libHN-Demo
//
//  Created by Ben Gordon on 10/6/13.
//  Copyright (c) 2013 subvertapps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNUser : NSObject

#pragma mark - Properties
@property (nonatomic, retain) NSString *Username;
@property (nonatomic, assign) int Karma;
@property (nonatomic, assign) int Age;
@property (nonatomic, retain) NSString *AboutInfo;


#pragma mark - Methods
+(HNUser *)userFromHTML:(NSString *)html;

@end
