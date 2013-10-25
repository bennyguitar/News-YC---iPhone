//
//  NavPurchaseProCell.m
//  HackerNews
//
//  Created by Ben Gordon on 10/25/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "NavPurchaseProCell.h"

@implementation NavPurchaseProCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setContentAndDelegate:(id)del {
    self.delegate = del;
    [self.PurchaseProButton addTarget:self action:@selector(didClickPurchasePro) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Actions
- (void)didClickPurchasePro {
    if ([self.delegate respondsToSelector:@selector(didSelectPurchasePro)]) {
        [self.delegate didSelectPurchasePro];
    }
}

@end
