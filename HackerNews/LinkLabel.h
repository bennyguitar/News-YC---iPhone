//
//  LinkLabel.h
//  HackerNews
//
//  Created by Ben Gordon on 9/21/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UILabelTapDelegate <NSObject>
- (void)didTapUILabelAtIndex:(NSInteger)index;
@end

@interface LinkLabel : UILabel

@property (weak) id <UILabelTapDelegate> delegate;

@end
