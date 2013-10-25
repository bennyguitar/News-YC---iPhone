//
//  NavPurchaseProCell.h
//  HackerNews
//
//  Created by Ben Gordon on 10/25/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#define kPurchaseProHeight 140

#import <UIKit/UIKit.h>

@protocol NavPurchaseProDelegate <NSObject>

- (void)didSelectPurchasePro;

@end

@interface NavPurchaseProCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *PurchaseProButton;
@property (weak) id <NavPurchaseProDelegate> delegate;

- (void)setContentAndDelegate:(id)del;

@end
