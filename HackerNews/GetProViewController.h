//
//  GetProViewController.h
//  HackerNews
//
//  Created by Ben Gordon on 10/24/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SatelliteStore.h"

@interface GetProViewController : UIViewController <SatelliteStoreDelegate>


- (IBAction)didClickPurchasePro:(id)sender;
- (IBAction)didClickRestorePro:(id)sender;

@end
