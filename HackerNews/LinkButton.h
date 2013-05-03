//
//  LinkButton.h
//  HackerNews
//
//  Created by Benjamin Gordon on 5/2/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kOrangeColor [UIColor colorWithRed:204/255.0f green:96/255.0f blue:52/255.0f alpha:1.0f]

@interface LinkButton : UIButton

@property (nonatomic, assign) int LinkTag;

+(LinkButton *)newLinkButtonWithTag:(int)tag linkTag:(int)lTag frame:(CGRect)frame title:(NSString *)title;

@end
