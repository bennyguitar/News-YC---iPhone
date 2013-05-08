//
//  User.m
//  HackerNews
//
//  Created by Benjamin Gordon on 5/5/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "User.h"

@implementation User

+(User *)userFromHTMLString:(NSString *)html {
    User *newUser = [[User alloc] init];
    
    // Scan HTML into strings
    NSString *trash=@"", *age=@"", *karma=@"", *about=@"";
    NSScanner *scanner = [NSScanner scannerWithString:html];
    [scanner scanUpToString:@"created:" intoString:&trash];
    [scanner scanString:@"created:</td><td>" intoString:&trash];
    [scanner scanUpToString:@" " intoString:&age];
    [scanner scanUpToString:@"karma:" intoString:&trash];
    [scanner scanString:@"karma:</td><td>" intoString:&trash];
    [scanner scanUpToString:@"</td>" intoString:&karma];
    [scanner scanUpToString:@"name=\"about\"" intoString:&trash];
    [scanner scanString:@"name=\"about\">" intoString:&trash];
    [scanner scanUpToString:@"</textarea>" intoString:&about];
    
    if (age.length == 0) {
        return nil;
    }
    if (karma.length == 0) {
        return nil;
    }
    
    newUser.Age = [age intValue];
    newUser.Karma = [karma intValue];
    newUser.AboutInfo = about;
    
    return newUser;
}

@end
