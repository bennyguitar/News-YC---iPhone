//
//  LinkButton.m
//  HackerNews
//
//  Created by Benjamin Gordon on 5/2/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "LinkButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Helpers.h"

@implementation LinkButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+(LinkButton *)newLinkButtonWithTag:(int)tag linkTag:(int)lTag frame:(CGRect)frame title:(NSString *)title {
    LinkButton *newLink = [[LinkButton alloc] initWithFrame:frame];
    [newLink setBackgroundColor:kOrangeColor];
    [newLink setTitle:title forState:UIControlStateNormal];
    [newLink.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [newLink setTitleColor:[UIColor colorWithWhite:0.98 alpha:1.0] forState:UIControlStateNormal];
    newLink.tag = tag;
    newLink.LinkTag = lTag;
    newLink.layer.cornerRadius = 10;
    newLink.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    newLink.titleLabel.adjustsFontSizeToFitWidth = YES;
    newLink.titleLabel.minimumScaleFactor = 0.5;
    newLink.titleLabel.numberOfLines = 1;
    [Helpers makeShadowForView:newLink withRadius:10];
    
    return newLink;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
