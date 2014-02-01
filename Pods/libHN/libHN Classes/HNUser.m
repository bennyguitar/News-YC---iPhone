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

#import "HNUser.h"
#import "HNUtilities.h"

@implementation HNUser

#pragma mark - New User from an HTML response
+(HNUser *)userFromHTML:(NSString *)html {
    // Make a new user
    HNUser *newUser = [[HNUser alloc] init];
    
    // Scan HTML into strings
    NSString *trash=@"", *age=@"", *karma=@"", *about=@"", *user=@"";
    NSScanner *scanner = [NSScanner scannerWithString:html];
    [scanner scanUpToString:@"user:</td><td>" intoString:&trash];
    [scanner scanString:@"user:</td><td>" intoString:&trash];
    [scanner scanUpToString:@"</td>" intoString:&user];
    [scanner scanUpToString:@"created:" intoString:&trash];
    [scanner scanString:@"created:</td><td>" intoString:&trash];
    [scanner scanUpToString:@" " intoString:&age];
    [scanner scanUpToString:@"karma:" intoString:&trash];
    [scanner scanString:@"karma:</td><td>" intoString:&trash];
    [scanner scanUpToString:@"</td>" intoString:&karma];
    [scanner scanUpToString:@"about:</td><td>" intoString:&trash];
    [scanner scanString:@"about:</td><td>" intoString:&trash];
    [scanner scanUpToString:@"</td>" intoString:&about];
    
    // Bad response
    if (age.length == 0) {
        return nil;
    }
    if (karma.length == 0) {
        return nil;
    }
    
    // Set properties
    newUser.Username = user;
    newUser.Age = [age intValue];
    newUser.Karma = [karma intValue];
    newUser.AboutInfo = [HNUtilities stringByReplacingHTMLEntitiesInText:about];
    
    return newUser;
}


@end
